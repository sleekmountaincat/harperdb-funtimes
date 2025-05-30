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
        operation: "search_by_value",
        table: "mtg_cards",
        database: "ci",
        search_attribute: "type",
        search_value: "*Dragon*",
        get_attributes: ["*"]
    }), {
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Basic ${encodedCredentials}`
        }
    });
    sleep(1);
}
