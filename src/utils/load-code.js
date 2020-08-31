// Helper method for deploy-contract that basically
// goes through the contract code and replaces certain 
// words (in our case addresses) with the addresses in 
// ../flow/addresses
export default async (url, match) => {
    const codeFile = await fetch(url);
    const rawCode = await codeFile.text();
    if (!match) {
        return rawCode;
    }

    const { query } = match;
    console.log(query)
    console.log(match)
    return rawCode.replace(query, (item) => {
        return match[item];
    });
};