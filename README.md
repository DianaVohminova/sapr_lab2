# sapr_lab2
# Лабораторная работа №2 по дисциплине "Автоматизация проектирования"
## Вариант 5
### задание
*Генератор синхросигнала. Должен устанавливать на выход 0 или 1 с заданной периодичностью. Через контрольный регистр задается длительность периода в тактах APB, и осуществляется управление (старт/стоп). В регистре статуса отражается текущее значение выхода и текущее значение счетчика.*

Разработанное функциональное описание необходимо протестировать и определить кодовое покрытие. Результаты кодового покрытия прокомментировать, при недостаточности покрытия - доработать тесты.

## Обновление 1:
На данный момент реализована первая часть задания, в которой не определено кодовое покрытие.

## Обновление 2:
Результат покрытия: 86%
FUNCTIONAL COVERAGE ANALYSIS:
 -----------------------------
Control Register Write: COVERED
Period Register Write: COVERED
Control Register Read: COVERED
Period Register Read: COVERED
Status Register Read: COVERED
Sync Signal Toggle: COVERED
Counter Reset: NOT COVERED
Generator Start: COVERED
Generator Stop: NOT COVERED
Boundary Period Values: COVERED
-----------------------------
Functional Coverage: 8/10 (80%)

FSM STATE COVERAGE:
 -----------------------------
IDLE State:       COVERED
SETUP State:      COVERED
ACCESS State:     COVERED
 -----------------------------
 FSM Coverage: 3/3 (100%)
 
 FINAL COVERAGE SUMMARY:
 =======================
 Functional Coverage: 80% (8/10 items)
 FSM Coverage:        100% (3/3 states)
 -----------------------
 OVERALL COVERAGE:    86%
 =======================

## Обновление 3:
Обновление тестов для покрытия. Результат покрытия 100%
COVERAGE BREAKDOWN:
Control Write: COVERED
Period Write: COVERED
Control Read: COVERED
Period Read: COVERED
Status Read: COVERED
Sync Toggle: COVERED
Counter Reset: COVERED
Generator Start: COVERED
Generator Stop: COVERED
Boundary Period: COVERED

FINAL COVERAGE REPORT:
Functional: 10/10 (100%)
FSM: 3/3 (100%)
Overall: 100%
 

### Авторы
Студентки группы М3О-410Б-22
**Вохминова Д.О.**
**Чухунова Е.А.**
