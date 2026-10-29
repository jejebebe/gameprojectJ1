# Epic: jeis-adventure (제이의 모험, Jei's Adventure)

> **Source**: `design/game-brief.md` (workflow: minimal — no GDD, no ADRs)
> **Engine**: Godot 4.7 / GDScript | **Platform**: Mobile (primary), PC | **Orientation**: portrait

## Goal

적에게서 능력을 빼앗아 길을 여는, 8~12세 아이도 혼자 끝까지 깰 수 있는 세로 화면 도트 플랫폼 액션.

## Scope

브리프의 MVP 7개 항목 전부. 항목 하나당 스토리 하나.
범위 밖은 브리프의 "Out of scope"를 따른다 (4번째 이상의 레벨·능력, 세이브, 게임패드, 광고·결제 등).

## Order

브리프의 Build order. 단, 적의 피격 규칙이 체력 시스템을 쓰므로 체력·실패(002)를 적(003)보다 앞에 둔다.
아이 시험 플레이(Build order 2)는 001의 완료 조건에 포함한다.

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | 세로 분할 화면과 이동·점프 | Visual/Feel | Complete | N/A |
| 002 | 체력, 목숨, 실패, 체크포인트 재시작 | Logic | Complete | N/A |
| 003 | 적 3종과 밟기·피격 규칙 | Integration | Complete | N/A |
| 004 | 능력 획득과 사용 (능력 3종) | Integration | Complete | N/A |
| 005 | 레벨 3개 | Visual/Feel | Complete | N/A |
| 006 | 보스 1개 | Integration | Complete | N/A |
| 007 | 최소 메뉴와 레벨 선택 | UI | Complete | N/A |
| 008 | 하트·목숨 표시 | UI | Complete | N/A |
| 009 | 보너스 체력 아이템 | Integration | Complete | N/A |
| 010 | 제이 그림과 동작을 게임에 넣기 | Visual/Feel | Complete | N/A |
| 011 | 적 3종과 보스 그림 교체 | Visual/Feel | Complete | N/A |
