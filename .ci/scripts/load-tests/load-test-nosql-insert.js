import http from 'k6/http';
import {sleep} from 'k6';
import encoding from 'k6/encoding';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

const username = 'harperdb';
const password = 'test';
const encodedCredentials = encoding.b64encode(`${username}:${password}`);

export let options = {
    vus: 50,
    duration: '30s',
};

export default function () {
    const res = http.post('http://localhost:9925', JSON.stringify({
        operation: "insert",
        table: "mtg_cards",
        database: "ci",
        records: [{
            id: `${uuidv4()}`,
            set: "EXTREME POWER",
            name: "fastidious homunculus",
            manaCost: "completely free",
            colors: "rainbow",
            type: "orc/gremlin hybrid with a dash of wizard",
            power: "100",
            toughness: "1000",
            artist: "ai generated",
            keywords: "none",
            originalText: "big ole baddy",
            flavorText: "chocolate"
        }]
    }), {
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Basic ${encodedCredentials}`
        }
    });
    sleep(1);
}

