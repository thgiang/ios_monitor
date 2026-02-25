# Hướng dẫn gửi Push cập nhật Live Activity từ Laravel

Tài liệu này mô tả **payload và headers** mà server Laravel cần gửi qua APNs để cập nhật Live Activity.

---

## 1. App iOS gửi gì lên server?

Khi Live Activity được khởi tạo, app sẽ gửi `POST` request đến URL bạn cấu hình trong màn hình Cấu hình (Push Token URL):

```json
POST {pushTokenURL}
Content-Type: application/json

{
  "push_token": "a1b2c3d4e5f6...",
  "device_id": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
  "store_ids": [1, 2, 5, 8]
}
```

| Trường | Mô tả |
|---|---|
| `push_token` | Token duy nhất của Live Activity — dùng để gửi push qua APNs |
| `device_id` | UUID thiết bị (`identifierForVendor`) — dùng để phân biệt các thiết bị |
| `store_ids` | Mảng `store_id` mà thiết bị đang theo dõi (lấy từ API monitor-all) |

**Phía Laravel cần:**
1. Lưu bản ghi `{ device_id, push_token, store_ids }`
2. Khi đơn hàng của store X thay đổi → tìm tất cả device có `store_ids` chứa X → gửi push đến `push_token` của các device đó

> **Lưu ý:** Token có thể thay đổi bất cứ lúc nào (khi app restart activity). App sẽ gửi token mới tự động — dùng `device_id` để cập nhật (upsert) thay vì tạo bản ghi mới.

---

## 2. Cấu hình APNs trên Apple Developer

1. Vào [Apple Developer → Keys](https://developer.apple.com/account/resources/authkeys/list)
2. Tạo Key mới → tick **Apple Push Notifications service (APNs)**
3. Download file `.p8` (chỉ download được 1 lần!)
4. Ghi nhớ: **Key ID**, **Team ID**, **Bundle ID** của app

---

## 3. Payload JSON gửi cho APNs

```json
{
  "aps": {
    "timestamp": 1740500000,
    "event": "update",
    "content-state": {
      "totalOrders": 15,
      "lateOrders": 3,
      "totalItems": 42,
      "lastUpdated": 1740500000
    }
  }
}
```

| Trường | Kiểu | Mô tả |
|---|---|---|
| `timestamp` | Integer | Unix timestamp (giây), **phải luôn tăng** so với lần trước |
| `event` | String | `"update"` để cập nhật, `"end"` để kết thúc Live Activity |
| `totalOrders` | Integer | Tổng số đơn hàng đang chờ |
| `lateOrders` | Integer | Số đơn hàng trễ |
| `totalItems` | Integer | Tổng số món |
| `lastUpdated` | Double | Unix timestamp (giây) — thời điểm cập nhật |

Nếu muốn kèm thông báo alert (tuỳ chọn):
```json
{
  "aps": {
    "timestamp": 1740500000,
    "event": "update",
    "content-state": { ... },
    "alert": {
      "title": "Cập nhật đơn hàng",
      "body": "Có 3 đơn trễ cần xử lý"
    }
  }
}
```

---

## 4. Headers cho APNs request

```
POST https://api.push.apple.com/3/device/{PUSH_TOKEN}

Headers:
  authorization: bearer {JWT_TOKEN}
  apns-topic: {BUNDLE_ID}.push-type.liveactivity
  apns-push-type: liveactivity
  apns-priority: 10
```

| Header | Giá trị |
|---|---|
| `apns-topic` | Bundle ID + `.push-type.liveactivity` |
| `apns-push-type` | `liveactivity` (bắt buộc) |
| `apns-priority` | `10` (gửi ngay) hoặc `5` (tiết kiệm pin) |

**Sandbox (dev):** `https://api.sandbox.push.apple.com/3/device/{PUSH_TOKEN}`  
**Production:** `https://api.push.apple.com/3/device/{PUSH_TOKEN}`

---

## 5. JWT Token cho APNs

Laravel cần tạo JWT (ES256) để xác thực với APNs:

```
Header: { "alg": "ES256", "kid": "{KEY_ID}" }
Payload: { "iss": "{TEAM_ID}", "iat": {unix_timestamp} }
Ký bằng: file .p8
```

Gợi ý package Laravel: [`laravel-notification-channels/apn`](https://github.com/laravel-notification-channels/apn) hoặc dùng trực tiếp `lcobucci/jwt` + `GuzzleHttp` với HTTP/2.

---

## 6. Xcode Capabilities cần bật (thủ công)

Bạn cần bật thủ công trong Xcode vì không thể làm từ code:

1. Mở project → chọn target **Order Manager** (app chính)
2. Tab **Signing & Capabilities** → **+ Capability**
3. Thêm **Push Notifications**
4. Thêm **Background Modes** → tick **Remote notifications**
