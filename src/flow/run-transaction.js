import * as fcl from "@onflow/fcl";
import * as sdk from "@onflow/sdk";
import * as types from "@onflow/types";
import loadCode from "../utils/load-code";

export default async (url, params) => {
    const { authorization } = fcl.currentUser();
    const code = await loadCode(url, params);

    return fcl.send([
        fcl.transaction(code),
        fcl.payer(authorization),
        fcl.proposer(authorization),
        fcl.authorizations([authorization]),
        fcl.limit(100)
    ]);
}