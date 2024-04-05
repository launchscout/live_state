use json_patch::diff;
use serde_json::{from_str, json};

#[rustler::nif]
fn build_patch_message(left: String, right: String, version: u32) -> String {
  let result = diff(&from_str(&left).unwrap(), &from_str(&right).unwrap());
  json!({ "patch": result, "version": version }).to_string()
}

rustler::init!("Elixir.LiveState.JSONDiffer", [build_patch_message]);
