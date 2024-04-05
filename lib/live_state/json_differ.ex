defmodule LiveState.JSONDiffer do
  use Rustler, otp_app: :live_state, crate: "livestate_jsondiffer"

  def build_patch_message(left, right, version), do: :erlang.nif_error(:nif_not_loaded)
end
