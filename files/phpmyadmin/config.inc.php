<?php
function isAccessFromPrivateNetwork() {
    $remote_addr = $_SERVER['REMOTE_ADDR'];
    if (strpos($remote_addr, "fe80::") === 0) return true;
    $arr = explode(".", $remote_addr);
    if (count($arr) !== 4) return false;
    $first_octet = intval($arr[0]);
    if ($first_octet === 10) return true;
    $second_octet = intval($arr[1]);
    if ($first_octet === 192 && $second_octet === 168) return true;
    return ($first_octet === 172 && $second_octet >= 16 && $second_octet <= 31);
}

$cfg['Servers'][1]['AllowNoPassword'] = isAccessFromPrivateNetwork();
?>
