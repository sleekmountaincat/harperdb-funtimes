import http from 'k6/http';
import {sleep} from 'k6';
import encoding from 'k6/encoding';

const username = 'harperdb';
const password = 'test';
const encodedCredentials = encoding.b64encode(`${username}:${password}`);

export let options = {
    vus: 50,
    duration: '30s',
};

export default function () {
    const res = http.post('http://localhost:9925', JSON.stringify({
        operation: "sql",
        sql: "SELECT colors, COUNT(*) FROM ci.mtg_cards GROUP BY colors"
    }), {
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Basic ${encodedCredentials}`
        }
    });
    sleep(1);
}
