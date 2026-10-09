package com.nandhu.spotless

import com.chaquo.python.PyObject
import com.chaquo.python.Python
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class MainActivity : AudioServiceActivity() {

    companion object {
        private const val CHANNEL = "spotless/ytdlp"

        // Timeouts (seconds) per Python call. Downloads of long songs take
        // minutes; everything else should finish well within 90s.
        const val TIMEOUT_DOWNLOAD = 300L
        const val TIMEOUT_DEFAULT = 90L
    }

    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val args: Map<String, Any?> =
                    call.arguments as? Map<String, Any?> ?: emptyMap()
                val timeout = if (call.method == "download") TIMEOUT_DOWNLOAD else TIMEOUT_DEFAULT
                when (call.method) {
                    "extract" -> async(result, timeout) { it.callAttr("extract", args["query"]) }
                    "search" -> async(result, timeout) {
                        it.callAttr("search", args["query"], args["max_results"] ?: 10)
                    }
                    "download" -> async(result, timeout) {
                        it.callAttr(
                            "download",
                            args["url"],
                            args["outdir"],
                            args["base_name"]
                        )
                    }
                    "embedCover" -> async(result, timeout) {
                        it.callAttr(
                            "embed_cover",
                            args["path"],
                            args["image_bytes"],
                            args["mime"]
                        )
                    }
                    "setTags" -> async(result, timeout) {
                        it.callAttr("set_tags", args["path"], args["title"], args["artist"])
                    }
                    "probe" -> async(result, timeout) { it.callAttr("probe", args["path"]) }
                    "getProgress" -> async(result, timeout) { it.callAttr("get_progress") }
                    "fetch_lyrics" -> async(result, timeout) {
                        it.callAttr(
                            "fetch_lyrics",
                            args["title"], args["artist"],
                            args["album"], args["duration_s"]
                        )
                    }
                    "canonical_search" -> async(result, timeout) {
                        it.callAttr(
                            "canonical_search",
                            args["artist"], args["title"],
                            args["expected_duration_s"], args["max_candidates"] ?: 8
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        executor.shutdown()
        super.onDestroy()
    }

    /**
     * Runs the Python call on the single background executor and waits for it
     * on a SEPARATE thread (never the executor thread and never the platform
     * channel/main thread), so a wedged yt-dlp times out after [timeoutSecs]
     * without deadlocking the executor or freezing the UI. NOTE: the timed-out
     * yt-dlp task keeps running on the executor; later calls queue behind it.
     */
    private fun async(result: MethodChannel.Result, timeoutSecs: Long, f: (PyObject) -> PyObject) {
        val waiter = Thread {
            try {
                // Explicit Callable: with the bare lambda the overload
                // resolution can pick Runnable, making Future.get() return
                // null and break every bridge call with an NPE on toString().
                val future: java.util.concurrent.Future<PyObject> =
                    executor.submit(java.util.concurrent.Callable {
                        android.util.Log.i("ytdlp", "calling python")
                        val module = Python.getInstance().getModule("ytdlp")
                        android.util.Log.i("ytdlp", "module loaded, invoking")
                        f(module)
                    })
                val pyResult = future.get(timeoutSecs, TimeUnit.SECONDS)
                android.util.Log.i("ytdlp", "python returned, encoding")
                if (pyResult == null) {
                    throw IllegalStateException("Python call returned null")
                }
                // Python side returns JSON strings (see ytdlp.py) so the
                // result is always a plain String the channel can encode.
                result.success(pyResult.toString())
                android.util.Log.i("ytdlp", "result sent")
            } catch (e: java.util.concurrent.TimeoutException) {
                android.util.Log.i("ytdlp", "timeout after ${timeoutSecs}s")
                result.error("YTDLP_ERROR", "Timed out after ${timeoutSecs}s", e.toString())
            } catch (e: Exception) {
                android.util.Log.i("ytdlp", "error: ${e.message}")
                result.error("YTDLP_ERROR", e.message, e.toString())
            }
        }
        waiter.isDaemon = true
        waiter.start()
    }
}
