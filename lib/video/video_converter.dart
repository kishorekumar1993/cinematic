// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';

class VideoConverter {
  static Future<void> convertWebmToMp4(
    Uint8List webmBytes,
  ) async {
    final ffmpeg = createFFmpeg(
      CreateFFmpegParam(
        log: true,
      ),
    );

    await ffmpeg.load();

    ffmpeg.writeFile(
      'input.webm',
      webmBytes,
    );

    await ffmpeg.run([
      '-i',
      'input.webm',
      '-c:v',
      'libx264',
      '-preset',
      'ultrafast',
      '-pix_fmt',
      'yuv420p',
      '-movflags',
      '+faststart',
      'output.mp4',
    ]);

    final Uint8List mp4Bytes =
        ffmpeg.readFile(
      'output.mp4',
    );

    final blob = html.Blob(
      [mp4Bytes],
      'video/mp4',
    );

    final url =
        html.Url.createObjectUrlFromBlob(
      blob,
    );

    final anchor =
        html.AnchorElement(
          href: url,
        )
          ..download = 'movie.mp4'
          ..style.display = 'none';

    html.document.body!.append(anchor);

    anchor.click();

    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }
}