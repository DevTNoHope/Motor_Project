FE/
├─ lib/
│  ├─ main.dart
│  ├─ core/
│  │  ├─ env.dart                   # BASE_URL
│  │  ├─ http_client.dart           # Dio client + interceptors (JWT)
│  │  └─ auth_guard.dart            # kiểm tra role, route guard
│  ├─ models/                       # M (Acc, User, Service, Booking,...)
│  ├─ controllers/                  # C (logic màn) - có thể dùng ChangeNotifier
│  ├─ services/                     # gọi API (AuthService, BookingService,...)
│  ├─ views/                        # V (screens/widgets)
│  │  ├─ auth/
│  │  ├─ profile/
│  │  ├─ vehicle/
│  │  ├─ service_list/
│  │  ├─ booking/
│  │  └─ mechanic/
│  ├─ routes/app_router.dart        # go_router config
│  └─ utils/
│     └─ formatters.dart
└─ pubspec.yaml
