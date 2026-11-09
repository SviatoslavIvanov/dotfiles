# Инвентаризация интерфейсов Pi 1.5.0

Область: закреплённое ядро, встроенные MCP/codemode/tool-search и **все 15 npm-пакетов**
из settings.json, а также локальные extensions. Навыки и prompt templates — текстовые
ответы в чате, не самостоятельные экраны. Внешние приложения и системные диалоги
учтены отдельно, но тема Pi ими не управляет.

Это карта поверхностей и проверок, **не утверждение, что все экраны визуально приняты**.
Установленная копия Pi не менялась. Единый стиль (см. README, «Единый UI») просмотрен
на реальном Pi 1.5.0 в изолированном `PI_CODING_AGENT_DIR` через tmux 120×35 в sv-dark и
sv-light, с локальным mock-провайдером вместо модели: все меню ниже, вопросы, `/tasks`,
просмотр вывода, подтверждение остановки, PTY-оверлей и его меню, виджеты активности,
сообщения мониторов. Ручной проход в Ghostty (мышь, IME, resize) по-прежнему нужен.

## Обозначения

- **S** — просмотрены точки входа/реализация по исходникам.
- **R** — реальный компонент отрисован в тесте, без запуска сети/LLM/действий пользователя.
- **B** — проверено конкретное поведение, указанное в строке.
- **S** без R/B — нельзя выдавать аудит исходников за runtime-проверку сценария.
- Проверка общего компонента не означает, что пройден каждый вызывающий его workflow.

## Ядро и встроенные расширения

| Экран / поверхность | Покрытие | Изменение / границы |
|---|---|---|
| Основной чат: user/assistant/thinking, Markdown, code, diff, картинки, свернутые/развернутые tools, errors, compaction/branch/skill messages | S | Сохранены существующие рендереры pi-polish и темы; нет новой визуальной приёмки всех типов сообщений |
| Редактор: черновик, очередь steering/follow-up, `/` и `@` completion, footer, scrollback/search в fullscreen | S | Существующие настройки и Nix-патчи; восстановление черновика после всех overlay вручную не проверено |
| `/model`, Ctrl+L: scope, search, provider/auth, current/default, refresh/error | S R B | ui.mjs: узкие размеры, применение модели, сохранение фокуса при refresh; текущая и выбранная модель различаются |
| `/models`: enable/disable, provider toggle, порядок, session-only vs Ctrl+S persist | S R B | screens.mjs: Enter меняет только session scope; persist вызывается отдельно; остальная логика штатная |
| `/settings`: список и вложенные select/search/stepped submenu; effort, тема, изображения | S R B | screens.mjs: основное меню, вложенные компоненты, переход вперёд/назад; ui.mjs: индексы children сохранены. Не перебраны изменения каждой настройки |
| `/tree` — экран с последнего скриншота | S R B | Компактные title/search/footer; штатная полная справка по F1; дерево не заменено. Поиск по кириллице, copy, выбор, метки, фильтр, Esc; длинное дерево и help укладываются в 24 строки |
| `/fork`: выбор пользовательского сообщения | S R B | Компактные внешние отступы; проверен штатный callback выбора, без реального fork |
| `/resume`, `pi --resume`: загрузка, scope/search/sort/named/path, rename/delete | S R B | Компактные внешние отступы; fixture loading/search/select/rename UI. Не удаляются и не переименовываются реальные файлы |
| Универсальные select/confirm/input/editor, включая timeout/abort | S R | Компактная рамка общих экспортируемых компонентов; без изменения последствий выбора и безопасности. Timeout/abort каждого вызывающего плагина не воспроизведён |
| `/login`, `/logout`: способ оплаты/провайдер, OAuth URL, device code/manual/API key/ambient auth, waiting/progress/error | S R B | Компактные общие auth-компоненты; fixture URL/waiting/prompt/submit. Нет настоящей авторизации, browser callback и проверки device-code polling |
| `/trust`: предупреждение, trusted/untrusted и update scope | S R | Штатный layout и все предупреждения сохранены; реальное решение не записывается |
| Первый запуск: theme + analytics | S R B | Оба шага отрисованы с fake callbacks; существующий профиль не сбрасывается |
| `pi config`: ресурсы/extensions/skills/prompts/themes, global/project scope | S R | Пустые fixture scopes с in-memory SettingsManager; реальные настройки не переключаются |
| `/mcp`: список, подключение/ошибка, server actions/tools, status, OAuth redirect | S R B | Собственный McpManagerView, а НЕ общий select. Проверены menu/status/redirect UI, удержание выбора при refresh, отмена auth. Серверы не подключаются |
| Codemode/tool-search/MCP tool output, notifications, welcome/help/hotkeys/changelog, onboarding/announcement messages | S | Текст/рендереры в основном чате; не самостоятельные selectors, не исключены из ручной приёмки |

R-проверки в screens.mjs проходят при ширине 40/80/120 в **sv-dark и sv-light**.
Это проверка строк и ширины TUI, а не скриншотный тест Ghostty, мыши или реального resize.

## Установленные npm-пакеты — без пропущенных UI-владельцев

| Пакет / вход | Поверхности и покрытие | Правки / что не запускалось |
|---|---|---|
| pi-polish | S R B; tools, diff, streaming/status/ожидание вопроса, hover и клики по группам, codemode в группах, хвост скрытого thinking | B в tmux: hover, закрытие кликом по выводу, сводки со скриптами на реальной сессии, 60 колонок; события вложенных вызовов прогнаны вне Pi. Живой codemode и стриминг thinking с моделью не запускались, курсор в Ghostty без tmux не проверен |
| pi-voice-stt `/stt`, Ctrl+R | S; profiles, speaker selection используют общий select; recording/errors/status — notifications/widget | Общий select R; запись, микрофон, разрешения macOS и оплачиваемая транскрипция не запускались |
| pi-web-access `/websearch`, `/curator`, `/search`, `/google-account` | S; stored-results/actions — общий select; search/fetch — tool renderer; curator — отдельная HTML-страница | Общий select R; browser curator имеет собственную light/dark CSS-палитру, не Catppuccin Pi. Cookies/login, поиск и summary approval не запускались |
| pi-interactive-shell `/spawn`, `/attach`, `/dismiss` | S; session select, launch approval, InteractiveShellOverlay, ReattachOverlay, output selector, widget/monitor events | ui.mjs B: адаптер монитора, output/events/stop; это не полный PTY/resize/detach-тест. Сохранён настоящий PTY, не имитация attach для bash |
| pi-bg-tasks `/bg`, `/bg-tasks` | S R B; widget, running/completed/error/cancelled tool output, task browser/log/stop | background.mjs: реальный локальный bash, wake-up/stop/reload cleanup; ui.mjs: список, output и подтверждение stop |
| pi-subagents-lite `/agents`, widget ↓ Enter | S; главное меню, running/queued + actions, spawn wizard (type/prompt/model/overrides), settings (model/concurrency/behavior/system prompt/widget), debug и conversation viewer/steering/continue | Общая собственная SettingsListWrapper уплотнена: нейтральные рамки/title, видимые Enter/Esc. screens.mjs R B: frame/navigation/prompt. Агенты не запускались; все экраны wizard/settings не пройдены end-to-end |
| pi-minimal-footer `/minfooter` | S; footer + status/help notifications, опциональный compact editor | extensions.mjs B: billing и история расходов. Основной footer не переделывался |
| pi-codemode-compact | S; компактный tool result, раскрытие вывода | Не отдельный экран настроек; оценка полного/свернутого результата остаётся в ручной приёмке |
| codex-computer-use-mcp `/computer-use-status` | S B; status notification, tool output с текстом и изображениями, официальные запросы runtime через общий select и editor | B: реальный `cua_repl` прочитал AX-дерево Finder и Linear, окна не вышли вперёд. Общий select R; собственных подтверждений действий у адаптера нет. Опасные действия не исполнялись |
| @juicesharp/rpiv-ask-user-question | S R B; tabs/options/multi-select/custom answer/notes/preview/collapse/submit/cancel | ui.mjs: content-sized dialog без пустого хвоста. Сочетания всех состояний и реальная работа фокуса/мыши — ручной чек |
| @pi-archimedes/image-paste | S; shortcut offer через общий confirm, attachment marker/preview/errors | Общий confirm R; clipboard, Quick Look и keybinding-файлы не изменяются ради проверки |
| @gamaraan/next-prompt `/next-prompt-config` | S B; widget над редактором, согласие на другой адрес модели через общий select, wizard настроек | B: в tmux widget показал подсказку, → вставил её без отправки. Общий select R; диалог согласия и wizard не открывались, wizard пишет в read-only конфиг |
| pi-editor-selection | S B; выделение Shift+стрелками и мышью, колесо по длинному промпту | B в tmux: Shift+← выделяет, `❯` и «voice ctrl+r» на месте при первом месте в packages. Копирование в буфер не запускалось |
| pi-codex-style-table | S B; таблицы в ответах, узкая ширина | B: 110 и 60 колонок, без предупреждения на старте. Копирование таблицы выделением не проверялось |
| @dietrichgebert/ponytail | S; `/ponytail*`, статус/help/report в чате | Не отдельное интерактивное окно; никакого редизайна текстовых отчётов или запуска агента ради UI |

## Локальные extensions

| Extension | Все поверхности | Покрытие |
|---|---|---|
| files.ts | `/files` picker/search; file actions; edit overlay; diff/Quick Look/reveal/open/add-to-prompt | S; нейтральные рамки/title, короткие hints, передача focus в search. Запись файлов и внешние приложения не проверялись |
| tasks.ts | `/tasks [kind]`, Ctrl+Shift+T; picker/search; per-task actions; output/events viewer; stop confirmation | S R B в ui.mjs; Esc не останавливает задачу, отказ подтверждения сохраняет процесс |
| ui-polish.ts | Model + общие selectors/input/editor/auth + tree/resume/fork | S R B; shutdown восстанавливает оригинальные методы. Привязка к внутренностям Pi 1.5.0 проверяется при обновлении |
| notify.ts | Только внешнее уведомление завершения | S; отдельного TUI-окна нет; OS-уведомление не переводится темой Pi |
| stash.ts | Alt+S, статус `stash` в footer | B в tmux: черновик уходит и возвращается, статус появляется и исчезает. Маркеры `[Image #N]` в отложенном черновике не проверялись |
| no-sleep.ts | `/no-sleep` status/help и notifications | S; нет отдельного списка/диалога |

## Единый стиль: что приведено и что осталось

Приведено (маркер `❯`, серые рамки, заголовок accent bold, keyHint-подсказки внутри рамки):
все экспортированные селекторы ядра, `SelectList`/`SettingsList` (автодополнение, меню
расширений), неэкспортированные trust/scoped models/MCP/config/setup/login menu/submenus
(при первом показе), `/tasks`, `/files`, вопросы, меню и виджет агентов, PTY-оверлей,
виджеты bash/монитора. `tests/screens.mjs` проверяет правила на каждом экране ядра.

Осталось — не считать исправленным:

1. У неэкспортированных экранов (trust, scoped models, MCP) сохранены собственные пустые
   строки и отступы: их мышь считает строки сама, поэтому меняется только оформление строк.
2. **Browser curator** имеет отдельную палитру и геометрию. Не выдавать его за
   приведённый к теме Pi только потому, что `/search` вызывает общий select.
3. **PTY overlays и transcript viewer** намеренно крупнее маленьких форм (рамка-коробка).
   Хром приведён, но проверять нужно читаемость, focus/scroll/resize/detach.
4. `/tree` показывает штатное «Type to search:» вместо `>`.
5. Страницы debug `/agents`, длинные descriptions, вложенные editors и prompt/model wizard
   требуют ручного прохода.

## Ручной маршрут после активации

Только после закрытия всех Pi-сессий, rebuild, restore и нового запуска:

1. Чат, длинный tool result/diff/image, Ctrl+O, completion `/`/`@`, fullscreen search,
   возврат с сохранением черновика. Затем 80×24 → 120×35 → resize → narrow window.
2. `/model`, `/models`, `/settings` и вложенные theme/effort/images/model overrides.
3. `/tree`: F1, search, filters, branch/fold, label edit/remove/cancel, copy, back.
   `/fork`; `/resume`: current/all, named, sort, path, rename; delete только на тестовой сессии.
4. Вопросы: 1–4 вкладки, multi-select, длинный текст, notes/custom answer, preview,
   collapse/return, submit/cancel; отсутствие пустого хвоста и доступность кнопок.
5. `/agents`: меню и все пять settings-подменю, debug, wizard до финального запуска
   (не запускать без отдельного согласия); существующий viewer, steering/stop — на fixture/разрешённом агенте.
6. `/tasks`, `/bg-tasks`, `/attach`, `/dismiss`: все типы, завершение во время просмотра,
   потеря/возврат фокуса, Esc/detach против confirmed stop.
7. `/files`: search/actions/edit/diff; Quick Look/open только по явному разрешению.
8. `/mcp`: empty/loading/connected/error, menu refresh, server details/tools, sign-in cancel.
   `/login` и `/trust` — сначала только open/cancel, без смены credentials/trust.
9. STT profiles/recording/cancel/error, stored search actions, browser curator отдельно,
   запросы Computer Use runtime с отказом, clipboard offer/attachment preview.
10. Light/dark, IME/кириллица, клавиатура/мышь, возврат в редактор с исходным черновиком.

Внешняя авторизация, первый запуск, разрешения macOS и удаление ресурсов не должны
выполняться на рабочем профиле ради косметической приёмки.
