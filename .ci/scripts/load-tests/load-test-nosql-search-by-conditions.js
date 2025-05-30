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
        operation: "search_by_conditions",
        database: "ci",
        table: "mtg_cards",
        operator: "and",
        get_attributes: ["*"],
        sort: {
            attribute: "power",
            next: {
                attribute: "name",
                descending: true
            }
        },
        conditions: [{
            search_attribute: "toughness",
            search_type: "contains",
            search_value: "6"
        }, {
            search_attribute: "type",
            search_type: "contains",
            search_value: "Human"
        }, {
            operator: "or",
            conditions: [{
                search_attribute: "power",
                search_type: "contains",
                search_value: "1"
            }, {
                search_attribute: "power",
                search_type: "contains",
                search_value: "2"
            }]
        }]
    }), {
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Basic ${encodedCredentials}`
        }
    });
    sleep(1);
}

