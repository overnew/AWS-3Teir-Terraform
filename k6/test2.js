// stress_test.js

import http from "k6/http";
import { sleep, check } from 'k6';

export let options = {
insecureSkipTLSVerify: true,
noConnectionReuse: false,
stages: [
    {
        duration: '120s',
        target: 3000
    },    
    {
        duration: '120s',
        target: 3000
    },
    {
        duration: '120s',
        target: 1000
    },
    {
        duration: '30s',
        target: 0
    }
],
};

export default function () {
const res = http.get('https://web-service-alb-454896588.ap-northeast-1.elb.amazonaws.com/');
check(res, { 'status was 200': (r) => r.status == 200 });
sleep(1);
};