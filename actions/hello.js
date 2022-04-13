function delay(time) {
    return new Promise(resolve => setTimeout(resolve, time));
} 

async function main() {
    await delay(1000);
    return { msg: 'Hello world' };
}
