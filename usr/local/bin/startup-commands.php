<?php
/**
 * A very simple script in charge of generating the startup commands based on environment variables.
 * The script is run on each start of the container.
 *
 * MIT License
 *
 * Copyright (c) 2018 TheCodingMachine
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

$commands = array_filter($_SERVER, function(string $key) {
    return strpos($key, 'STARTUP_COMMAND') === 0;
}, ARRAY_FILTER_USE_KEY);

ksort($commands);

echo "set -e\n";


// Let's run the commands as user $UID if env variable UID is set.

foreach ($commands as $command) {
    $line = $command;
    if (isset($_SERVER['UID'])) {
        $line = 'sudo -E -u \\#'.$_SERVER['UID'].' bash -c '.escapeshellarg($line);
    }
    echo $line."\n";
}
