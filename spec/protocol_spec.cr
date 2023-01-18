require "./spec_helper"

describe Protocol do
  it "float cookie time converter" do
    fixture = %q|{"cookies":[{"name":"PHPSESSID","value":"62f45503698e0bc9bd5547d3cd329d0d","domain":"beebox.dev.vuln.nexploit.app","path":"/","expires":-1,"size":41,"httpOnly":false,"secure":false,"session":true,"priority":"Medium","sameParty":false,"sourceScheme":"Secure","sourcePort":443},{"name":"security_level","value":"0","domain":"beebox.dev.vuln.nexploit.app","path":"/","expires":1705586435.968834,"size":15,"httpOnly":false,"secure":false,"session":false,"priority":"Medium","sameParty":false,"sourceScheme":"Secure","sourcePort":443},{"name":"security_level","value":"0","domain":"beebox.dev.vuln.nexploit.app","path":"/","expires":1705586435,"size":15,"httpOnly":false,"secure":false,"session":false,"priority":"Medium","sameParty":false,"sourceScheme":"Secure","sourcePort":443}]}|

    res = Protocol::Network::GetAllCookies.from_json(fixture)
    res.cookies.size.should eq 3
  end
end
