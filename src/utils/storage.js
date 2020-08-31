let dataArray = []

export const storeData = (user) => {
    for (let i = 0; i < dataArray.length; i++) {
        if (dataArray[i].name === user.identity.name) {
            return
        }
    }
    dataArray.push({ name: user.identity.name, addr: user.addr })
}

export const data = dataArray