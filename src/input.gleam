/// Input module: bridges Gleam with a small JavaScript FFI
///
/// This module provides a simple `read_line` function for receiving
/// user input when running the program under the JavaScript target.
///
/// Internally it calls an external JavaScript function defined in
/// `input_ffi.mjs`, which performs the actual prompt and input read.
/// External JavaScript function for reading a single line of input.
///
/// `prompt` — the message shown to the user before waiting for input.
///
/// The underlying implementation lives in `input_ffi.mjs`.
@external(javascript, "./input_ffi.mjs", "read_line")
fn js_read_line(prompt: String) -> String

/// Read a line of input from the user.
///
/// This is the public wrapper around the JavaScript FFI function.
/// It simply forwards the prompt and returns whatever string
/// the JavaScript side provides.
pub fn read_line(prompt: String) -> String {
  js_read_line(prompt)
}
