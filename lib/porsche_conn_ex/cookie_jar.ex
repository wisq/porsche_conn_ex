defmodule PorscheConnEx.CookieJar do
  def child_spec(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)

    %{
      id: __MODULE__,
      start: {CookieJar, :start_link, [opts]}
    }
  end

  def with_cookies(%Req.Request{} = req) do
    req
    |> Req.Request.append_request_steps(load_cookies: &load/1)
    |> Req.Request.append_response_steps(save_cookies: &save/1)
  end

  defp save({request, response}) do
    CookieJar.pour(
      __MODULE__,
      Req.Response.get_header(response, "set-cookie"),
      request.url
    )

    {request, response}
  end

  defp load(request) do
    Req.Request.put_header(
      request,
      "cookie",
      CookieJar.to_string(__MODULE__, request.url)
    )
  end
end
