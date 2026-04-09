## Задание 3. Безопасность в облачных провайдерах - Выполнил Shestovskikh Daniil

### Шифрование бакета Object Storage через KMS

**Что сделано:**

1. Создан симметричный ключ в KMS (Yandex Key Management Service)
2. Настроено шифрование бакета `dun9-images-bucket-uk0i89` через созданный ключ
3. Проверено, что файлы в бакете шифруются автоматически

### Результаты

| Параметр | Значение |
|----------|----------|
| ID ключа KMS | `abjfcccfjfp3gijhgf3` |
| Алгоритм | AES_256 |
| Статус ключа | ACTIVE |
| Период ротации | 8760h (1 год) |

### Проверка шифрования

При запросе файла из бакета в заголовках ответа присутствует:

```
x-amz-server-side-encryption: aws:kms
```

### Скриншоты

![Задание 3](screenshots/task3.png)

### Файлы конфигурации

| Файл | Назначение |
|------|------------|
| [`kms.tf`](https://github.com/Dun9Dev/clopro-hw2/blob/main/kms.tf) | Создание KMS ключа |
| [`storage.tf`](https://github.com/Dun9Dev/clopro-hw2/blob/main/storage.tf) | Бакет с шифрованием через KMS |

