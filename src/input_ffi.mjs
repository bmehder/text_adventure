// JavaScript FFI for Gleam (text_adventure project)
// -------------------------------------------------
// This file exposes a synchronous `read_line` function, used by the
// Gleam module `input.gleam` when the project is compiled to the
// JavaScript target.
//
// It prints a prompt to stdout, waits for user input on stdin, and
// returns the entered text with trailing newline characters removed.

import fs from 'node:fs'

/**
 * Read a single line of user input from stdin.
 *
 * @param {string} prompt - The text printed before waiting for input.
 * @returns {string} The user's input, trimmed of trailing newlines.
 */
export function read_line(prompt) {
	// Print prompt
	process.stdout.write(prompt)

	// Read synchronously from /dev/stdin
	const buffer = Buffer.alloc(1024)
	const bytes = fs.readSync(0, buffer, 0, 1024, null)
	const input = buffer.toString('utf8', 0, bytes)

	return input.trimEnd()
}
