import jwt
import json
import time
import requests
import textwrap

city = 'ningbo'
location = 'yinzhou'
api_host = 'https://pp4ewpuqme.re.qweatherapi.com'


def get_encode_jwt() -> str:
    private_key = '-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEIHJZIl8cHpdYG+5IBCJQMEiQal8HcLsYd5ymInTPPP5n\n-----END PRIVATE KEY-----'
    payload = {
        'iat': int(time.time()) - 30,
        'exp': int(time.time()) + 900,
        'sub': '252HMCVH4Q'
    }
    jwt_headers = { 'kid': 'KFWG2P7VHK' }
    return jwt.encode(payload, private_key, algorithm='EdDSA', headers=jwt_headers)

get_headers = {
    'Authorization': f'Bearer {get_encode_jwt()}',
    'Accept-Encoding': 'gzip, deflate'
}

def get_request(request_path, params):
    response = requests.get(f'{api_host}{request_path}', headers=get_headers,params=params)
    if response.status_code == 200:
        return response.json()
    raise Exception


def get_location(city, location) -> tuple[str, str]:
    request_path = f'/geo/v2/city/lookup'
    params = {'location': location, 'adm': city}
    data = get_request(request_path, params)
    latitude = data['location'][0]['lat']
    longitude = data['location'][0]['lon']
    return (latitude, longitude)


def get_location_string(latitude, longitude):
    request_path = f'/geo/v2/city/lookup'
    latitude = f'{float(latitude):.2f}'
    longitude = f'{float(longitude):.2f}'
    params = {'location':f'{longitude},{latitude}'}
    data = get_request(request_path,params)
    province = data['location'][0]['adm1']
    city = data['location'][0]['adm2']
    name = data['location'][0]['name']
    return f' {city}{name}'


def get_weather(latitude, longitude):
    request_path = f'/v7/weather/24h'
    params = {'location': f'{longitude},{latitude}'}
    data = get_request(request_path, params)
    hourly_weather = data['hourly'][0]
    return hourly_weather


def get_tips(latitude, longitude):
    request_path = f'/v7/indices/1d'
    params = {'location': f'{longitude},{latitude}', 'type': 3}
    data = get_request(request_path, params)
    tips = data['daily'][0]
    return tips


def get_warnings(latitude, longitude):
    request_path = f'/v7/warning/now'
    params = params = {'location': f'{longitude},{latitude}'}
    data = get_request(request_path, params)
    warnings = data['warning']
    return warnings


def parse_warning_info(warning_json):
    type_name = warning_json['typeName']
    warning_severity = warning_json['severity']
    color_string = ''
    match warning_severity.lower():
        case "minor":
            color_string = "蓝色预警"
        case "moderate":
            color_string = "黄色预警"
        case "severe":
            color_string = "橙色预警"
        case "extreme":
            color_string = "红色预警"
        case _: 
            color_string = "未知等级预警"
    return f' {type_name}{color_string}'


try:
    latitude, longitude = get_location(city, location)
    hourly_weather = get_weather(latitude, longitude)
    today_tips = get_tips(latitude, longitude)
    warnings = get_warnings(latitude, longitude)
    weather_text = hourly_weather['text']
    temp = hourly_weather['temp']
    tips_text = f'{get_location_string(latitude, longitude)}\n'
    if len(warnings) != 0:
        for warning in warnings:
            tips_text += parse_warning_info(warning)
    tips_text += textwrap.fill(f' {today_tips['text']}', width=15)
    
    output = {
        'text': f' {weather_text} {temp}℃',
        'tooltip': tips_text,
    }
    print(json.dumps(output))
except requests.RequestException:
    output = {
        'text': 'Network disconnected',
        'tooltip': 'No tips data'
    }
    print(json.dumps(output))
except Exception:
    output = {
        'text': 'No weather data',
        'tooltip': 'No tips data'
    }
    print(json.dumps(output))
