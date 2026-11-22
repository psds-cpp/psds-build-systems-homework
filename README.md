# psds-build-systems-homework

Домашнее задание по теме "Системы сборки" в Школе Разработчиков ООО "Прософт-Системы".

## Краткое описание репозитория

В этом репозитории находится незавершенный проект PBKDF2.
Одноименный стандарт [PBKDF2](https://ru.wikipedia.org/wiki/PBKDF2)
часто используется для хэширования паролей пользователей.
Хэши можно безопасно хранить в базах данных, в отличие от открытого
текста паролей.

Исходный код проекта в репозитории реализован полностью.
Вносить в него какие-либо изменения не требуется.

В домашнем задании требуется добавить сборку проекта и упаковку
его в пакет Conan.

## Описание проекта PBKDF2

Артефактами проекта являются:

- Исполняемый файл `derive_key` &mdash; на основе аргументов
  командной строки хэширует переданный пользователем пароль.
  Исходный код `derive_key` находится в папке [src/](./src).

- Библиотека `libpbkdf2` &mdash; реализует связанные с шифрованием
  функции проекта.
  Исходный код `libpbkdf2` находится в папке [src/](./src),
  публичные заголовочные файлы &mdash; в папке [include/](./include).

Пример использования `derive_key`:
```
$ ./derive_key --help
PKCS5 PBKDF2 HMAC key derivation app


/home/czert/Projects/Prosoft/psds-cpp/psds-build-systems-homework/build/Release/derive_key [OPTIONS] password


POSITIONALS:
  password TEXT REQUIRED      Password to derive key from

OPTIONS:
  -h,     --help              Print this help message and exit
  -v,     --version           Display program version information and exit
  -s,     --salt TEXT         Salt
  -i,     --iter UINT [10]    Iterations number
          --saltsize, --ss UINT [64]
                              generated salt size, bytes
          --keysize, --ks UINT [64]
                              key size, bytes
$ ./derive_key --ss 16 --ks 16 'qwerty12345'
{
    "hash": "27ce605588d1b3c67b07fba34f569521",
    "salt": "9516b7b97c3cd985bb72cc318e494700"
}
```

## Инструкция к выполнению задания

### 1. Подготовка репозитория

1. Создайте приватную копию данного репозитория.
1. Пригласите пользователя `@czertyaka` в качестве коллаборатора.
1. Включите в своем проекте GitHub Actions.
1. Склонируйте репозиторий на машину Linux с установленным Docker.
1. Создайте ветку `development` и всю разработку ведите в ней.

### 2. Подготовка сборочного окружения

В этом домашнем задании вам предстоит выполнять кросс-компиляцию (для Windows x86_64
и Linux AArch64).
Каждая из этих платформ требует установки специальных средств компиляции
(тулчейнов).
Самый простой и переносимый способ распространять сборочные окружения с разными
тулчейнами &mdash; через образы Docker и их рецепты.
Такой [рецепт](./Dockerfile) подготовлен и в этом репозитории.

Для запуска shell в сборочном окружении выполните:

```sh
./docker-run.sh
```

Скрипт соберет образ Docker, установив в него все необходимые для разработки
инструменты, и запустит в нем `bash`.

> [!NOTE]
> Первый запуск скрипта может длиться достаточно долго.
> Чтобы отслеживать прогресс сборки образа Docker, добавьте флаг `-v` в команду
> запуска скрипта.
> Последующие запуски контейнера будут происходить быстрее.

Запущенный контейнер:
- монтирует текущую директорию (с этим репозиторием), все результаты сборки
  будут сохраняться между перезапусками контейнера;
- устанавливает переменную окружения `CONAN_HOME` в `./.conan2`, все скачанные
  и созданные пакеты будут сохраняться в ней (и также сохраняться между
  перезапусками контейнера);
- предоставляет кросс-тулчейны для Windows x86_64, Linux AArch64 и пакетный
  менеджер Conan;
- удалится самостоятельно, когда вы из него выйдете.

Для генерации профиля Conan по умолчанию выполните:

```sh
$ conan profile detect --force
```

### 3. Разработка CMakeLists.txt

В корне проекта создайте **CMakeLists.txt**.
В нем необходимо описать сборку проекта.

#### 3.1. Требования

1. Проект должен через `find_package` находить следующие пакеты:
    - `nlohmann_json` (используется для составления JSON-строки для вывода `derive_key`)
    - `CLI11` (используется для парсинга аргументов командной строки `derive_key`)
    - `OpenSSL` (используется для реализации криптографических функций в проекте)

    Если хотя бы один из них не нашелся, то должна быть ошибка конфигурации
    CMake.

2. Проект должен определять библиотеку `pbkdf2`.

    Библиотека должна состоять из:
    - `src/pbkdf2.cxx` (единица трансляции);
    - `include/pbkdf2.hpp` (публичный заголовок);
    - `include/pbkdf2/compatibility.hpp` (публичный заголовок).

    Библиотека должна приватно линковаться с:
    - `OpenSSL::Crypto`.

    Библиотека должна публично компилироваться с дефинициями препроцессора:
    - `PBKDF2_VERSION` (версия библиотеки, берется из рецепта Conan);
    - `PBKDF2_STATIC` (только если собирается статическая версия библиотеки).

3. Проект должен определять исполняемый файл `derive_key`.

    Файлы с исходным кодом `derive_key`:
    - `src/app_arguments.cxx` (единица трансляции)
    - `src/main.cxx` (единица трансляции)
    - `src/hex.cxx` (единица трансляции)
    - `src/app_arguments.hpp` (приватный заголовок)
    - `src/hex.hpp` (приватный заголовок)

    `derive_key` должен приватно линковаться с:
    - `pbkdf2` (библиотека из п. выше);
    - `nlohmann_json::nlohmann_json`
    - `CLI11::CLI11`

4. Команда установки CMake должна в месте установки создавать[^note]:
    ```
    .
    ├── bin
    │   └── derive_key
    ├── include
    │   ├── pbkdf2
    │   │   └── compatibility.hpp
    │   └── pbkdf2.hpp
    └── lib
        └── libpbkdf2.so
    ```

  [^note]: Имена библиотеки и исполняемого файла могут отличаться для разных операционных
  систем и опций сборки.

#### 3.2. Подсказки

- Используйте `include(GNUInstallDirs)` для автоматического создания
  директорий `bin`, `include` и `lib` во время установки.

- Используйте `BUILD_SHARED_LIBS` для определения, какой вариант
  библиотеки собирается.

- Используйте `target_sources` + `FILE_SET HEADERS` для назначения
  цели сборки набора публичных заголовков.

### 4. Разработка conanfile.py

В корне проекта создайте **conanfile.py**.
В нем необходимо описать создание пакета Conan.

#### 4.1. Требования

1. Имя пакета должно быть `pbkdf2`.

2. Версия пакета должна быть `0.1.0`.

3. Пакет должен определять опции `shared` (default = `False`) и `fPIC`
    (default = `True`).
    Опция `fPIC` должна удаляться при сборке для Windows и при `shared` = `True`.

4. Пакет должен экспортировать все необходимые для сборки исходники.

5. Пакет должен определять зависимости:
    - `openssl/[>=3 <4]`
    - `cli11/[>=2 <3]`
    - `nlohmann_json/[>=3 <4]`

6. Пакет должен использовать генераторы `CMakeDeps`, `CMakeToolchain` и
    `cmake_layout`.

7. Пакет должен сообщать версию из `self.version` в систему сборки
    CMake для корректного определения значения дефиниции препроцессора
    `PBKDF2_VERSION`.

8. Пакет должен сообщать потребителям дефиницию препроцессора
    `PBKDF2_STATIC` для случая `shared` = `False`.


#### 4.2. Подсказки

- Экспортировать исходники можно через атрибут `exports_sources`.

- Для удаления опции `fPIC` используйте следующие методы:
    ```python
        def config_options(self):
            if self.settings.os == "Windows":
                self.options.rm_safe("fPIC")

        def configure(self):
            if self.options.shared:
                self.options.rm_safe("fPIC")
    ```

- Используйте `CMakeToolchain` для передачи дефиниции с версией, например:
    ```python
        tc = CMakeToolchain(self)
        tc.cache_variables["PBKDF2_PROJECT_VERSION"] = self.version
    ```

- Используйте `collect_libs` из `conan.tools.files` для указания библиотек
    в `package_info`.

- Используйте `self.cpp_info.defines` для сообщения потребителям
    дефиниций препроцессора.

### 5. Сборка

На этом этапе можно выполнить первую сборку для ручного тестирования.
Выполните:

```shell
$ conan build . --build=missing
```

> [!NOTE]
> В последующих запусках `--build=missing` можно опустить.
> В кэше уже окажутся собранные зависимости проекта, сборка будет происходить
> быстрее.

Для тестирования выполните:

```shell
$ ./build/Release/derive_key -v
0.1.0
```

### 6. Создание пакета

Выполните создание пакета:

```shell
$ conan create .
```

После успешного создания пакета
произойдет тестирование пакета в директории `test_package/`.
Эта директория является тестовым потребителем вашего пакета, она линкуется
с библиотекой `libpbkdf2.a`.

```
...
======== Testing the package: Executing test ========
pbkdf2/1.0.1 (test package): Running test()
pbkdf2/1.0.1 (test package): RUN: ./example
v1.0.1
```

### 7. Кросс-компиляция

Создайте директорию `conan-profiles`.

#### 7.1. Linux AArch64

В сборочном окружении установлен тулчейн `aarch64-linux-gnu-*` для компиляции
под Linux AArch64.
Например, так выглядит вызов компилятора:

```shell
$ aarch64-linux-gnu-g++ --version
aarch64-linux-gnu-g++ (Debian 14.2.0-19) 14.2.0
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

1. Создайте профиль для компиляции под Linux AArch64 по пути
    `conan-profiles/aarch64-linux-gnu`.

2. Самостоятельно определите содержимое секции `[settings]`.

3. Установите в профиле следующие переменные окружения сборки:
    - `CC` = `aarch64-linux-gnu-gcc`
    - `CXX` = `aarch64-linux-gnu-g++`
    - `AR` = `aarch64-linux-gnu-ar`
    - `RANLIB` = `aarch64-linux-gnu-ranlib`
    - `STRIP` = `aarch64-linux-gnu-strip`

4. Выполните сборку под Linux AArch64:
    ```shell
    $ conan create . -pr:h conan-profiles/aarch64-linux-gnu --build=missing
    ```

#### 7.2. Windows x86_64

В сборочном окружении установлен тулчейн [mingw-w64](https://www.mingw-w64.org/)
для сборки под Windows x86_64.

Например, так выглядит вызов компилятора:

```shell
$ x86_64-w64-mingw32-g++ --version
x86_64-w64-mingw32-g++ (GCC) 14-win32
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

1. Создайте профиль для компиляции под Windows x86_64 по пути
    `conan-profiles/x86_64-w64-mingw32`.

2. Самостоятельно определите содержимое секции `[settings]`.
    Добавьте в него следующие строки:
    ```
    compiler.threads=win32
    compiler.exception=seh
    ```

3. Установите в профиле следующие переменные окружения сборки:
    - `CC` = `x86_64-w64-mingw32-gcc`
    - `CXX` = `x86_64-w64-mingw32-g++`
    - `RC` = `x86_64-w64-mingw32-windres`
    - `LDFLAGS` = `-static-libgcc -static-libstdc++`

4. Выполните сборку под Windows x86_64:
    ```shell
    $ conan create . -pr:h conan-profiles/x86_64-w64-mingw32 --build=missing
    ```

Если все прошло успешно, можно скопировать полученный `derive_key.exe` на
машину Windows и запустить из терминала (не обязательное требованиe).

### 8. Проверка

Выполните скрипт `./check.sh` в сборочном окружении для проверки, что все было
сделано правильно.

### 9. Пулл-реквест

Создайте в своем приватном репозитории пулл-реквест из ветки `development` в
`master`, добавьте `@czertyaka` в ревьюверы и ожидайте проверки домашнего
задания.

## Решение

Решение в зашифрованном виде находится в директории [`solution/`](/solution/README.md).
