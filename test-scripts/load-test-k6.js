import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 200 },
    { duration: '15m', target: 200 },
    { duration: '30s', target: 0 },
  ],
};

export default function() {
  const url = 'http://song-app.songs.svc.cluster.local:8080/songs'
  //const url = 'http://${__ENV.SONG_APP}:8080/songs/'
  let headers = {'Content-Type': 'application/json'};
  let data = '{"author":"Matt Bellamy","id":234567,"name":"Uprising","op":"ADD"}'
  let res =  http.post(url,data, {headers: headers});
  res = http.post(url, data, {headers: headers});
  console.log('status: ' + res.status);

};
