// stress_test.js

import http from "k6/http";
import { sleep, check } from 'k6';

export let options = {
insecureSkipTLSVerify: true,
noConnectionReuse: false,
stages: [
{ duration: '2m', target: 100 },
{ duration: '5m', target: 100 },
{ duration: '2m', target: 200 },
{ duration: '5m', target: 200 },
{ duration: '2m', target: 300 },
{ duration: '5m', target: 300 },
{ duration: '2m', target: 400 },
{ duration: '5m', target: 400 },
{ duration: '10m', target: 0 },
],
};

export default function () {
const res = http.get('http://172.31.44.52/');
check(res, { 'status was 200': (r) => r.status == 200 });
sleep(1);
};