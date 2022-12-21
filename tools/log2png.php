<?php
$src = __DIR__ . '/txt/*.txt';
$is_overwrite = true;
$ignore_files = []; //['0005', '0006', '0012', '0039', '0041'];

function tEXt($key, $val='')
{
    $str = $key. "\0". $val;
    return pack('N', strlen($str)). 'tEXt'. $str. pack('N', crc32('tEXt'. $str));
}

foreach (glob($src) as $path) {
    $fn = pathinfo($path, PATHINFO_FILENAME);
    if (in_array($fn, $ignore_files)) continue;

    $dst = dirname($src) . '/../png/' . $fn . '.png';
    if (!$is_overwrite && file_exists($dst)) continue;

    $txt = file_get_contents($path);

    ob_start();
    $im = imagecreate(1, 1);
    imagecolorallocate($im, 0, 0, 0);
    imagepng($im);
    $png = ob_get_clean();
    imagedestroy($im);

    $text = tEXt('parameters', $txt);
    $iend = hex2bin('0000000049454e44ae426082');
    $png = str_replace($iend, $text . $iend, $png);

    file_put_contents($dst, $png);
}
