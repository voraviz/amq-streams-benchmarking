import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 1000 },
    { duration: '15m', target: 1000 },
    { duration: '30s', target: 0 },
  ],
};

export default function() {
  const url = 'https://song-songs.apps.cluster-f2cc.f2cc.example.opentlc.com/songs';
  let headers = {'Content-Type': 'application/json'};
  let data = '{"author":"Matt Bellamy","id":234567,"name":"Uprising","op":"ADD"}'
  //let res = http.post(url, JSON.stringify(data), {headers: headers});
  let res =  http.post(url,data, {headers: headers});
  //console.log(JSON.parse(res.body).json.name);

  //headers = {'Content-Type': 'application/x-www-form-urlencoded'};

  res = http.post(url, data, {headers: headers});
  console.log('status: ' + res.status);
  // check(res, { 'status was 200': r => r.status == 200 });
  //console.log(JSON.parse(res.body).form.name);
};
