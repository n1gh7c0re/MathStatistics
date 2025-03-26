## 1. Спецификация API (OpenAPI / Swagger)

Начну с представления спецификации API с основными endpoint'ами:

```yaml
openapi: 3.0.0
info:
  title: Client Payment Blocking API
  description: API для управления блокировками платежей клиентов в Т-банке
  version: 1.0.1
servers:
  - url: https://api.tbank.ru/v1
    description: Production server

paths:
  /clients/{clientId}/blocks:
    post:
      summary: Заблокировать платежи клиента
      description: Создает новую блокировку для клиента с указанием причины
      parameters:
        - name: clientId
          in: path
          required: true
          schema:
            type: string
          description: Уникальный идентификатор клиента
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/BlockRequest'
      security:
        - ApiKeyAuth: []
        - BearerAuth: []
      responses:
        '201':
          description: Блокировка успешно создана
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/BlockResponse'
        '400':
          description: Неверный запрос (например, некорректные данные)
        '409':
          description: Клиент уже имеет активную блокировку
        '404':
          description: Клиент не найден

  /clients/{clientId}/blocks/active:
    delete:
      summary: Снять активную блокировку клиента
      description: Устанавливает дату завершения для активной блокировки
      parameters:
        - name: clientId
          in: path
          required: true
          schema:
            type: string
          description: Уникальный идентификатор клиента
      security:
        - ApiKeyAuth: []
        - BearerAuth: []
      responses:
        '200':
          description: Блокировка успешно снята
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UnblockResponse'
        '404':
          description: Активная блокировка не найдена или клиент не существует
        '403':
          description: Нет прав на снятие блокировки (опционально, если роли введены)

  /clients/{clientId}/blocks/status:
    get:
      summary: Проверить статус блокировки клиента
      description: Возвращает информацию о текущем статусе блокировки клиента
      parameters:
        - name: clientId
          in: path
          required: true
          schema:
            type: string
          description: Уникальный идентификатор клиента
      security:
        - ApiKeyAuth: []
      responses:
        '200':
          description: Статус блокировки клиента
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/BlockStatus'
        '404':
          description: Клиент не найден

  /clients/{clientId}/blocks/history:
    get:
      summary: Получить историю блокировок клиента
      description: Возвращает список всех блокировок клиента (активных и завершенных)
      parameters:
        - name: clientId
          in: path
          required: true
          schema:
            type: string
          description: Уникальный идентификатор клиента
      security:
        - ApiKeyAuth: []
        - BearerAuth: []
      responses:
        '200':
          description: История блокировок клиента
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/BlockResponse'
        '404':
          description: Клиент не найден

components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  schemas:
    BlockRequest:
      type: object
      properties:
        reason:
          type: string
          enum: [FRAUD, INCORRECT_DETAILS]
          description: Причина блокировки (мошенничество или неверные реквизиты)
        comment:
          type: string
          description: Дополнительный комментарий (опционально)
      required:
        - reason
    BlockResponse:
      type: object
      properties:
        id:
          type: string
          description: Уникальный идентификатор блокировки
        clientId:
          type: string
          description: Идентификатор клиента
        reason:
          type: string
          enum: [FRAUD, INCORRECT_DETAILS]
          description: Причина блокировки
        blockedAt:
          type: string
          format: date-time
          description: Дата и время установки блокировки
        resolvedAt:
          type: string
          format: date-time
          nullable: true
          description: Дата и время снятия блокировки (null, если активна)
        comment:
          type: string
          nullable: true
          description: Дополнительный комментарий
      required:
        - id
        - clientId
        - reason
        - blockedAt
    UnblockResponse:
      type: object
      properties:
        id:
          type: string
          description: Уникальный идентификатор снятой блокировки
        clientId:
          type: string
          description: Идентификатор клиента
        resolvedAt:
          type: string
          format: date-time
          description: Дата и время снятия блокировки
      required:
        - id
        - clientId
        - resolvedAt
    BlockStatus:
      type: object
      properties:
        isBlocked:
          type: boolean
          description: Заблокирован ли клиент в данный момент
        reason:
          type: string
          enum: [FRAUD, INCORRECT_DETAILS]
          nullable: true
          description: Причина текущей блокировки (null, если нет активной)
        blockedAt:
          type: string
          format: date-time
          nullable: true
          description: Дата и время установки текущей блокировки (null, если нет активной)
        comment:
          type: string
          nullable: true
          description: Дополнительный комментарий к текущей блокировке
      required:
        - isBlocked
```

### Описание endpoint'ов:
1. **`POST /clients/{clientId}/blocks`** — Устанавливает блокировку для клиента с указанием причины (`FRAUD_SUSPICION` или `INVALID_DETAILS`) и опциональным комментарием
2. **`DELETE /clients/{clientId}/blocks/active`** — Снимает активную блокировку с клиента
3. **`GET /clients/{clientId}/blocks/status`** — Возвращает текущий статус блокировки клиента, включая причину и время установки блокировки
4. **`GET /clients/{clientId}/blocks/history`** - Возвращает полную историю блокировок клиента

### Описание разделов `components`:
1. **`securitySchemes`** - Определяет механизмы аутентификации для API
   - **`ApiKeyAuth`** - Простой способ защиты, требует API-ключ в запросах
   - **`BearerAuth`** - Более сложный и гибкий способ, поддерживает роли и scopes
2. **`schemas`** - Определяет переиспользуемые структуры данных для запросов и ответов
   - **`BlockRequest`** - Данные для создания блокировки
   - **`BlockResponse`** - Полная информация о блокировке (для создания и истории)
   - **`UnblockResponse`** - Подтверждение снятия блокировки
   - **`BlockStatus`** - Текущий статус блокировки клиента

## 2. Структура базы данных

Для хранения информации о блокировках предлагаю создать таблицу `client_blocks`, которая будет связана с таблицей клиентов (`clients`) по идентификатору клиента

### Таблица `clients`
Эта таблица хранит базовую информацию о клиентах. Она нужна как справочная, чтобы связать блокировки с конкретными клиентами

| Поле            | Тип данных       | Описание                                                                 | Ограничения                  |
|-----------------|------------------|--------------------------------------------------------------------------|------------------------------|
| `id`            | `UUID`           | Уникальный идентификатор клиента                                        | PRIMARY KEY, DEFAULT gen_random_uuid() |
| `name`          | `VARCHAR(100)`   | Название юридического лица или имя клиента                              | NOT NULL                     |
| `status`        | `VARCHAR(20)`    | Статус клиента (например, "ACTIVE", "INACTIVE")                         | NOT NULL, DEFAULT 'ACTIVE'   |
| `created_at`    | `TIMESTAMP`      | Дата и время создания записи о клиенте                                  | NOT NULL, DEFAULT NOW()      |
| `updated_at`    | `TIMESTAMP`      | Дата и время последнего обновления записи                               | NOT NULL, DEFAULT NOW() ON UPDATE NOW() |

#### Пояснения:
- **`id`** - UUID нужен для уникальности в распределенных системах
- **`name`** - Хранит название компании или имя клиента
- **`status`** - Простое перечисление для отслеживания активности клиента
- **`created_at` и `updated_at`** - Для аудита и отслеживания изменений

---

### Таблица `payment_blocks`
Эта таблица хранит информацию о блокировках платежей клиентов, включая активные и завершенные записи

| Поле            | Тип данных       | Описание                                                                 | Ограничения                  |
|-----------------|------------------|--------------------------------------------------------------------------|------------------------------|
| `id`            | `UUID`           | Уникальный идентификатор записи о блокировке                            | PRIMARY KEY, DEFAULT gen_random_uuid() |
| `client_id`     | `UUID`           | Идентификатор клиента, к которому относится блокировка                  | NOT NULL, FOREIGN KEY        |
| `reason`        | `VARCHAR(20)`    | Причина блокировки ("FRAUD" или "INCORRECT_DETAILS")                    | NOT NULL, CHECK              |
| `comment`       | `TEXT`           | Дополнительный комментарий к блокировке (опционально)                   | NULLABLE                     |
| `created_at`    | `TIMESTAMP`      | Дата и время создания блокировки                                        | NOT NULL, DEFAULT NOW()      |
| `resolved_at`   | `TIMESTAMP`      | Дата и время снятия блокировки (NULL, если блокировка активна)          | NULLABLE                     |
| `created_by`    | `VARCHAR(50)`    | Идентификатор сотрудника или системы, создавшей блокировку              | NOT NULL                     |
| `resolved_by`   | `VARCHAR(50)`    | Идентификатор сотрудника или системы, снявшей блокировку (NULL, если активна) | NULLABLE               |
| `updated_at`    | `TIMESTAMP`      | Дата и время последнего обновления записи                               | NOT NULL, DEFAULT NOW() ON UPDATE NOW() |

#### Пояснения:
- **`id`** - Уникальный идентификатор каждой блокировки (UUID для масштабируемости)
- **`client_id`** - Связь с таблицей `clients` через внешний ключ
- **`reason`** - Ограничено значениями "FRAUD" и "INCORRECT_DETAILS" для соответствия API
- **`comment`** - Текстовое поле для дополнительных пояснений (например, "Клиент предоставил неверный ИНН")
- **`created_at`** - Временная метка создания блокировки
- **`resolved_at`** - Временная метка снятия блокировки; если NULL, блокировка активна
- **`created_by`** - Кто инициировал блокировку (например, логин сотрудника или "SYSTEM")
- **`resolved_by`** - Кто снял блокировку (NULL, если блокировка не снята)
- **`updated_at`** - Автоматически обновляется при изменении записи

---

### Приведу пример данных

#### Таблица `clients`
| id                                   | name                | status  | created_at          | updated_at          |
|--------------------------------------|---------------------|---------|---------------------|---------------------|
| `550e8400-e29b-41d4-a716-446655440000` | ООО "Ромашка"       | ACTIVE  | 2025-03-01 10:00:00 | 2025-03-01 10:00:00 |
| `6ba7b810-9dad-11d1-80b4-00c04fd430c8` | ЗАО "Василек"       | ACTIVE  | 2025-03-02 14:30:00 | 2025-03-02 14:30:00 |

#### Таблица `payment_blocks`
| id                                   | client_id                            | reason           | comment                     | created_at          | resolved_at         | created_by | resolved_by | updated_at          |
|--------------------------------------|--------------------------------------|------------------|-----------------------------|---------------------|---------------------|------------|-------------|---------------------|
| `e7f6c011-8c9d-4e2b-bcde-123456789abc` | `550e8400-e29b-41d4-a716-446655440000` | FRAUD            | Подозрение на мошенничество | 2025-03-10 09:15:00 | NULL                | user123    | NULL        | 2025-03-10 09:15:00 |
| `f8e9d012-9d0e-5f3c-cdef-987654321def` | `6ba7b810-9dad-11d1-80b4-00c04fd430c8` | INCORRECT_DETAILS| Неверный ИНН                | 2025-03-15 12:00:00 | 2025-03-16 14:00:00 | system     | user153     | 2025-03-16 14:00:00 |

#### Исходя из примера, можно увидеть, что:
- Клиент "ООО Ромашка" имеет активную блокировку из-за подозрения на мошенничество (`resolved_at` NULL).
- Клиент "ЗАО Василек" имел блокировку из-за неверных реквизитов, но она была снята 16 марта 2025 года.

---

### Логика работы
- **`POST /clients/{clientId}/blocks`**: Создает новую запись в `payment_blocks` с `resolved_at = NULL`
- **`DELETE /clients/{clientId}/blocks/active`**: Обновляет существующую запись, устанавливая `resolved_at` и `resolved_by`
- **`GET /clients/{clientId}/blocks/status`**: Проверяет, есть ли запись с `resolved_at IS NULL` для данного `client_id`
- **`GET /clients/{clientId}/blocks/history`**: Возвращает все записи для `client_id`, включая завершенные
