package com.example.homeroleplay

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {

    private val channelName = "homeroleplay/server"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "queryServer" -> {
                    val host = call.argument<String>("host") ?: ""
                    val port = call.argument<Int>("port") ?: 7001
                    val timeoutMs = call.argument<Int>("timeoutMs") ?: 2500

                    Thread {
                        val response = queryServer(host, port, timeoutMs)
                        runOnUiThread {
                            result.success(response)
                        }
                    }.start()
                }

                "connectToServer" -> {
                    /*
                     * Bagian ini nantinya digunakan untuk
                     * membuka client SA-MP Android.
                     *
                     * Untuk sekarang hanya mengembalikan true.
                     */
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun queryServer(
        host: String,
        port: Int,
        timeoutMs: Int
    ): Map<String, Any> {
        val address = "$host:$port"
        var socket: DatagramSocket? = null

        return try {
            val ip = InetAddress.getByName(host)

            socket = DatagramSocket()
            socket.soTimeout = timeoutMs

            // Query server info
            val infoPacket = buildQueryPacket(ip, port, 'i')
            val start = System.currentTimeMillis()

            socket.send(infoPacket)

            val buffer = ByteArray(8192)
            val received = DatagramPacket(buffer, buffer.size)

            socket.receive(received)

            val ping = (System.currentTimeMillis() - start).toInt()
            val info = parseInfoPacket(received.data, received.length)

            // Query server rules
            val rules = try {
                val rulesPacket = buildQueryPacket(ip, port, 'r')
                socket.send(rulesPacket)

                val rulesReceived = DatagramPacket(buffer, buffer.size)
                socket.receive(rulesReceived)

                parseRulesPacket(rulesReceived.data, rulesReceived.length)
            } catch (_: Exception) {
                emptyMap()
            }

            val version = rules["version"]
                ?: rules["Version"]
                ?: "Tidak terdeteksi"

            val maintenanceValue = rules["maintenance"]
                ?: rules["Maintenance"]
                ?: rules["status"]

            val maintenance = maintenanceValue
                ?.lowercase()
                ?.let {
                    it in setOf(
                        "1",
                        "true",
                        "yes",
                        "on",
                        "maintenance",
                        "maint"
                    )
                }
                ?: false

            val stormValue = rules["storm"]
                ?: rules["Storm"]
                ?: rules["badai"]
                ?: rules["Badai"]

            val storm = stormValue
                ?.lowercase()
                ?.let {
                    it in setOf(
                        "1",
                        "true",
                        "yes",
                        "on",
                        "storm",
                        "badai",
                        "active"
                    )
                }
                ?: false

            val versionLower = version.lowercase()

            val serverType = when {
                versionLower.contains("open.mp") ||
                        versionLower.contains("openmp") ||
                        versionLower.contains("omp") -> {
                    "open.mp"
                }

                version != "Tidak terdeteksi" -> {
                    "SA-MP"
                }

                else -> {
                    "SA-MP/open.mp"
                }
            }

            mapOf(
                "online" to true,
                "maintenance" to maintenance,
                "storm" to storm,
                "hostname" to (info["hostname"] ?: "-"),
                "address" to address,
                "players" to (info["players"] ?: 0),
                "maxPlayers" to (info["maxPlayers"] ?: 0),
                "gamemode" to (info["gamemode"] ?: "-"),
                "language" to (info["language"] ?: "-"),
                "ping" to ping,
                "serverType" to serverType,
                "version" to version,
                "weather" to (rules["weather"] ?: rules["Weather"] ?: "-"),
                "worldTime" to (rules["worldtime"] ?: rules["WorldTime"] ?: "-"),
                "error" to ""
            )

        } catch (e: Exception) {
            mapOf(
                "online" to false,
                "maintenance" to false,
                "storm" to false,
                "hostname" to "Server Offline",
                "address" to address,
                "players" to 0,
                "maxPlayers" to 0,
                "gamemode" to "-",
                "language" to "-",
                "ping" to 0,
                "serverType" to "-",
                "version" to "-",
                "weather" to "-",
                "worldTime" to "-",
                "error" to (e.message ?: "UDP query timeout")
            )
        } finally {
            socket?.close()
        }
    }

    private fun buildQueryPacket(
        ip: InetAddress,
        port: Int,
        opcode: Char
    ): DatagramPacket {
        val bytes = ip.address

        if (bytes.size != 4) {
            throw IllegalArgumentException(
                "Server harus menggunakan IPv4 untuk query SA-MP"
            )
        }

        val data = ByteArray(11)

        data[0] = 'S'.code.toByte()
        data[1] = 'A'.code.toByte()
        data[2] = 'M'.code.toByte()
        data[3] = 'P'.code.toByte()

        data[4] = bytes[0]
        data[5] = bytes[1]
        data[6] = bytes[2]
        data[7] = bytes[3]

        data[8] = (port and 0xFF).toByte()
        data[9] = ((port shr 8) and 0xFF).toByte()
        data[10] = opcode.code.toByte()

        return DatagramPacket(data, data.size, ip, port)
    }

    private fun parseInfoPacket(
        data: ByteArray,
        length: Int
    ): Map<String, Any> {
        if (length < 16 || data[10].toInt().toChar() != 'i') {
            throw IllegalStateException("Respons SA-MP/open.mp info tidak valid")
        }

        var offset = 11

        val password = data[offset].toInt() != 0
        offset += 1

        val players = readUInt16LE(data, offset)
        offset += 2

        val maxPlayers = readUInt16LE(data, offset)
        offset += 2

        val hostnameResult = readLengthPrefixedString(data, length, offset)
        offset = hostnameResult.second

        val gamemodeResult = readLengthPrefixedString(data, length, offset)
        offset = gamemodeResult.second

        val languageResult = readLengthPrefixedString(data, length, offset)

        return mapOf(
            "password" to password,
            "players" to players,
            "maxPlayers" to maxPlayers,
            "hostname" to hostnameResult.first,
            "gamemode" to gamemodeResult.first,
            "language" to languageResult.first
        )
    }

    private fun parseRulesPacket(
        data: ByteArray,
        length: Int
    ): Map<String, String> {
        if (length < 13 || data[10].toInt().toChar() != 'r') {
            throw IllegalStateException("Respons rules tidak valid")
        }

        var offset = 11

        val ruleCount = readUInt16LE(data, offset)
        offset += 2

        val rules = mutableMapOf<String, String>()

        for (i in 0 until ruleCount) {
            if (offset >= length) break

            val nameLength = data[offset].toInt() and 0xFF
            offset += 1

            if (offset + nameLength > length) break

            val name = decodeString(data.copyOfRange(offset, offset + nameLength))
            offset += nameLength

            if (offset >= length) break

            val valueLength = data[offset].toInt() and 0xFF
            offset += 1

            if (offset + valueLength > length) break

            val value = decodeString(data.copyOfRange(offset, offset + valueLength))
            offset += valueLength

            rules[name] = value
        }

        return rules
    }

    private fun readLengthPrefixedString(
        data: ByteArray,
        length: Int,
        offset: Int
    ): Pair<String, Int> {
        if (offset + 4 > length) {
            throw IllegalStateException("String length tidak lengkap")
        }

        val stringLength = readUInt32LE(data, offset)
        val start = offset + 4
        val end = start + stringLength

        if (end > length || stringLength < 0) {
            throw IllegalStateException("String server terpotong")
        }

        val value = decodeString(data.copyOfRange(start, end))

        return Pair(
            if (value.isBlank()) "-" else value,
            end
        )
    }

    private fun decodeString(bytes: ByteArray): String {
        return try {
            String(bytes, Charsets.UTF_8)
        } catch (_: Exception) {
            String(bytes, Charset.forName("Windows-1252"))
        }
    }

    private fun readUInt16LE(data: ByteArray, offset: Int): Int {
        return (data[offset].toInt() and 0xFF) or
                ((data[offset + 1].toInt() and 0xFF) shl 8)
    }

    private fun readUInt32LE(data: ByteArray, offset: Int): Int {
        return (data[offset].toInt() and 0xFF) or
                ((data[offset + 1].toInt() and 0xFF) shl 8) or
                ((data[offset + 2].toInt() and 0xFF) shl 16) or
                ((data[offset + 3].toInt() and 0xFF) shl 24)
    }
}