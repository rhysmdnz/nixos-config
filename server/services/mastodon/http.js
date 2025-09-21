function decoded(r) {
  if (!("resource" in r.args)) {
    return "";
  }
  let lookup_expression = /acct:(.+)@personaldomain.example/;
  var match = r.args["resource"].match(lookup_expression);
  if (!match || match.length == 0) {
    return "";
  }
  return match[1];
}

async function webfinger(r) {
  try {
    const res = await ngx.fetch(
      "https://social.memes.nz/.well-known/webfinger?" + r.variables.args
    );
    if (!res.ok) {
      r.return(res.status);
      return;
    }
    const js = await res.json();
    js.links.push({
      rel: "http://openid.net/specs/connect/1.0/issuer",
      href: "https://account.memes.nz/realms/master",
    });
    r.headersOut["Content-Type"] = "application/jrd+json; charset=utf-8";
    r.return(200, JSON.stringify(js));
    return;
  } catch (e) {
    r.error(e);
  }
}

export default { webfinger };
