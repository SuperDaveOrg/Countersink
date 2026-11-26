package com.superdavelab.countersink

import android.app.Activity
import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.view.KeyEvent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter UI, plus the "countersink/documents" channel used for backups
 * and the "countersink/app" channel for the version, the keep-screen-on flag,
 * counting with the volume keys, the home-screen widgets and the
 * quick-settings tile.
 *
 * Backups go through Android's own Save and Open pickers (the Storage Access
 * Framework). The user chooses where the file goes; Countersink only ever touches the one
 * document the user picked, and needs no storage permission to do it. This is a
 * few lines of platform code rather than a plugin so there is no dependency
 * that could merge a permission back into the manifest.
 */
class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null
    private val main = Handler(Looper.getMainLooper())
    private var appChannel: MethodChannel? = null
    private var volumeMode = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Small things asked of Android directly rather than through a plugin,
        // so no dependency can merge a permission back in.
        val app = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_CHANNEL)
        appChannel = app
        app.setMethodCallHandler { call, result ->
                when (call.method) {
                    // The installed version, shown in Settings so a bug report
                    // can say which build it's about.
                    "version" -> {
                        val info = packageManager.getPackageInfo(packageName, 0)
                        val code = if (Build.VERSION.SDK_INT >= 28) {
                            info.longVersionCode
                        } else {
                            @Suppress("DEPRECATION") info.versionCode.toLong()
                        }
                        result.success(mapOf("name" to info.versionName, "code" to code))
                    }
                    // Keeps the screen from dimming and locking while the app
                    // is in front. A window flag, which needs no permission
                    // and stops applying the moment the app is left.
                    "keepScreenOn" -> {
                        if (call.arguments == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    // Which volume keys count instead of changing the volume:
                    // 0 none, 1 up only, 2 up and down. The app sets this
                    // while a counter is in full screen and clears it after.
                    "volumeKeys" -> {
                        volumeMode = (call.arguments as? Int) ?: 0
                        result.success(null)
                    }
                    // Hands a web address to the phone's browser, for the
                    // Website and Send feedback rows in Settings. The app
                    // still has no internet permission: the browser loads
                    // the page, and nothing from the app goes with it.
                    "openLink" -> {
                        val opened = try {
                            startActivity(
                                Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String))
                                    .addCategory(Intent.CATEGORY_BROWSABLE)
                            )
                            true
                        } catch (e: Exception) {
                            // No browser, or nothing that takes the address.
                            false
                        }
                        result.success(opened)
                    }
                    // The home-screen widgets, redrawn after counts made in
                    // the app.
                    "refreshWidgets" -> {
                        CounterWidget.updateAll(this)
                        result.success(null)
                    }
                    // Whether a widget has counted since this was last
                    // asked; asking clears it.
                    "takeWidgetCounts" -> result.success(WidgetStore.takeCounted(this))
                    // The counter the quick-settings tile adds to, or null.
                    "tileCounter" -> result.success(WidgetStore.tileCounter(this))
                    "setTileCounter" -> {
                        WidgetStore.setTileCounter(this, call.arguments as? String)
                        CounterTileService.refresh(this)
                        result.success(null)
                    }
                    // Asks Android to offer the tile for the quick settings.
                    // True if it is there afterwards; false if it was turned
                    // down or this Android can't be asked (before 13), when
                    // the app explains how to add it by hand.
                    "addTile" -> {
                        if (Build.VERSION.SDK_INT >= 33) {
                            var answered = false
                            getSystemService(StatusBarManager::class.java).requestAddTileService(
                                ComponentName(this, CounterTileService::class.java),
                                getString(R.string.widget_name),
                                Icon.createWithResource(this, R.drawable.ic_tile),
                                mainExecutor,
                            ) { code ->
                                if (!answered) {
                                    answered = true
                                    result.success(
                                        code == StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ADDED ||
                                            code == StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ALREADY_ADDED,
                                    )
                                }
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    // Whether this home screen can be asked to add a widget.
                    "canPinWidget" -> result.success(CounterWidget.canPin(this))
                    // Asks the home screen to add a widget for one counter.
                    "pinWidget" -> result.success(
                        CounterWidget.pin(this, call.arguments as? String ?: ""),
                    )
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (pendingResult != null) {
                    result.error("busy", "A file picker is already open.", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "save" -> launchPicker(
                        result,
                        Intent(Intent.ACTION_CREATE_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            .setType(call.argument<String>("mimeType") ?: "application/json")
                            .putExtra(Intent.EXTRA_TITLE, call.argument<String>("name")),
                        REQUEST_SAVE,
                        call.argument<ByteArray>("bytes"),
                    )
                    "open" -> launchPicker(
                        result,
                        Intent(Intent.ACTION_OPEN_DOCUMENT)
                            .addCategory(Intent.CATEGORY_OPENABLE)
                            // Providers label JSON inconsistently, so offer
                            // anything and let the Dart side validate it.
                            .setType("*/*"),
                        REQUEST_OPEN,
                    )
                    // A folder for automatic backups. The user picks it once
                    // and Android remembers that this app may write there,
                    // and nowhere else.
                    "pickFolder" -> launchPicker(
                        result,
                        Intent(Intent.ACTION_OPEN_DOCUMENT_TREE),
                        REQUEST_FOLDER,
                    )
                    "writeToFolder" -> writeToFolder(
                        result,
                        Uri.parse(call.argument<String>("folder")),
                        call.argument<String>("name")!!,
                        call.argument<ByteArray>("bytes")!!,
                        call.argument<String>("prefix")!!,
                        call.argument<Int>("keep")!!,
                    )
                    "releaseFolder" -> {
                        try {
                            contentResolver.releasePersistableUriPermission(
                                Uri.parse(call.argument<String>("folder")),
                                FOLDER_ACCESS,
                            )
                        } catch (e: Exception) {
                            // Already gone: nothing to give back.
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * While the app has asked for them, the volume keys are handed to it as
     * counts and go no further, so the volume doesn't move and its slider
     * doesn't appear. A key held down counts once: the repeats Android
     * sends while it is held are swallowed, and so is the release.
     */
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val direction = when {
            volumeMode == 0 -> 0
            event.keyCode == KeyEvent.KEYCODE_VOLUME_UP -> 1
            event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN && volumeMode == 2 -> -1
            else -> 0
        }
        if (direction == 0) return super.dispatchKeyEvent(event)
        if (event.action == KeyEvent.ACTION_DOWN && event.repeatCount == 0) {
            appChannel?.invokeMethod("volumeKey", direction)
        }
        return true
    }

    /**
     * Opens the system picker, or replies with an error straight away if it
     * can't — some stripped-down or managed devices have no document provider.
     * Either way nothing is left pending, so the next attempt isn't "busy".
     */
    private fun launchPicker(
        result: MethodChannel.Result,
        intent: Intent,
        requestCode: Int,
        bytes: ByteArray? = null,
    ) {
        pendingResult = result
        pendingBytes = bytes
        try {
            startActivityForResult(intent, requestCode)
        } catch (e: Exception) {
            pendingResult = null
            pendingBytes = null
            result.error("no_picker", "This phone has no file picker to use.", null)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_SAVE && requestCode != REQUEST_OPEN &&
            requestCode != REQUEST_FOLDER
        ) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult ?: return
        val bytes = pendingBytes
        pendingResult = null
        pendingBytes = null

        val uri: Uri? = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null) // backed out
            return
        }

        if (requestCode == REQUEST_FOLDER) {
            try {
                // Kept across restarts, until the app gives it back or the
                // user takes it away.
                contentResolver.takePersistableUriPermission(uri, FOLDER_ACCESS)
                result.success(mapOf("uri" to uri.toString(), "name" to folderName(uri)))
            } catch (e: Exception) {
                result.error("io", e.message, null)
            }
            return
        }

        // File I/O off the main thread; reply on it, as the channel requires.
        Thread {
            try {
                if (requestCode == REQUEST_SAVE) {
                    contentResolver.openOutputStream(uri, "wt")!!.use { it.write(bytes!!) }
                    main.post { result.success(true) }
                } else {
                    val read = contentResolver.openInputStream(uri)!!.use {
                        it.readAtMost(MAX_BYTES + 1)
                    }
                    main.post {
                        if (read.size > MAX_BYTES) {
                            result.error("too_large", "That file is too large to be a Countersink backup.", null)
                        } else {
                            result.success(read)
                        }
                    }
                }
            } catch (e: Exception) {
                main.post { result.error("io", e.message, null) }
            }
        }.start()
    }

    /** What the folder is called, for showing in Settings. */
    private fun folderName(tree: Uri): String {
        val folder = DocumentsContract.buildDocumentUriUsingTree(
            tree, DocumentsContract.getTreeDocumentId(tree))
        contentResolver.query(
            folder, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null,
        )?.use { if (it.moveToFirst()) return it.getString(0) ?: "" }
        return ""
    }

    /**
     * Writes [bytes] as [name] in the folder the user picked, over a file of
     * that name if there is one, then deletes all but the newest [keep] of the
     * files there whose names start with [prefix]. Names carry their date, so
     * newest is last in the alphabet. Only files with that prefix are ever
     * touched: the folder may hold anything else.
     */
    private fun writeToFolder(
        result: MethodChannel.Result,
        tree: Uri,
        name: String,
        bytes: ByteArray,
        prefix: String,
        keep: Int,
    ) {
        Thread {
            try {
                val folderId = DocumentsContract.getTreeDocumentId(tree)
                val folder = DocumentsContract.buildDocumentUriUsingTree(tree, folderId)
                val files = mutableMapOf<String, Uri>()
                contentResolver.query(
                    DocumentsContract.buildChildDocumentsUriUsingTree(tree, folderId),
                    arrayOf(
                        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                        DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    ),
                    null, null, null,
                )?.use {
                    while (it.moveToNext()) {
                        files[it.getString(1) ?: continue] =
                            DocumentsContract.buildDocumentUriUsingTree(tree, it.getString(0))
                    }
                }

                val target = files[name]
                    ?: DocumentsContract.createDocument(contentResolver, folder, "application/json", name)
                    ?: throw java.io.IOException("The folder would not take a new file.")
                contentResolver.openOutputStream(target, "wt")!!.use { it.write(bytes) }
                files[name] = target

                val ours = files.keys.filter { it.startsWith(prefix) }.sortedDescending()
                for (old in ours.drop(keep)) {
                    try {
                        DocumentsContract.deleteDocument(contentResolver, files[old]!!)
                    } catch (e: Exception) {
                        // An old copy that won't go is not worth failing over.
                    }
                }
                main.post { result.success(true) }
            } catch (e: Exception) {
                main.post { result.error("io", e.message, null) }
            }
        }.start()
    }

    /** Reads at most [limit] bytes, so a huge file picked by mistake can't exhaust memory. */
    private fun java.io.InputStream.readAtMost(limit: Int): ByteArray {
        val out = java.io.ByteArrayOutputStream()
        val buf = ByteArray(8192)
        while (out.size() < limit) {
            val n = read(buf, 0, minOf(buf.size, limit - out.size()))
            if (n < 0) break
            out.write(buf, 0, n)
        }
        return out.toByteArray()
    }

    private companion object {
        const val CHANNEL = "countersink/documents"
        const val APP_CHANNEL = "countersink/app"
        const val REQUEST_SAVE = 0x4E01
        const val REQUEST_OPEN = 0x4E02
        const val REQUEST_FOLDER = 0x4E03
        const val FOLDER_ACCESS =
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION

        /** Hundreds of thousands of taps come to well under this. */
        const val MAX_BYTES = 64 * 1024 * 1024
    }
}
