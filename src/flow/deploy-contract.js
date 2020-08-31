import * as fcl from "@onflow/fcl";
import * as sdk from "@onflow/sdk";
import * as types from "@onflow/types";
import loadCode from "../utils/load-code";

export default async (url, params) => {
  const user = fcl.currentUser();
  const { authorization } = user;
  const code = await loadCode(url, params);

  console.log("Authorization")
  console.log(authorization)

  return fcl.send(
    [
      sdk.transaction`
          transaction {
            prepare(acct: AuthAccount) {
              acct.setCode("${(p) => p.code}".decodeHex())
            }
          }
        `,
      fcl.params([
        fcl.param(Buffer.from(code, "utf8").toString("hex"), types.Identity, "code"),
      ]),
      fcl.proposer(authorization),
      fcl.payer(authorization),
      fcl.authorizations([authorization]),
      fcl.limit(100)
    ],
    {
      node: "http://localhost:8080"
    }
  );
};