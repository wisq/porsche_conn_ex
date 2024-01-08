defmodule PorscheConnEx.Cookies do
  def using_jar(%Req.Request{} = request, jar) do
    request
    |> Req.Request.append_request_steps(load_cookies: &load(jar, &1))
    |> Req.Request.append_response_steps(save_cookies: &save(jar, &1))
  end

  defp save(jar, {request, response}) do
    CookieJar.pour(
      jar,
      Req.Response.get_header(response, "set-cookie"),
      request.url
    )

    {request, response}
  end

  defp load(jar, request) do
    request
    |> Req.Request.put_header(
      "cookie",
      CookieJar.to_string(jar, request.url)
    )
  end
end
