rule CIPHER_SAFE_TEST_DETECTION
{
    meta:
        description = "Harmless 999 Cipher detection test"

    strings:
        $test = "999_CIPHER_SAFE_DETECTION_TEST"

    condition:
        $test
}
