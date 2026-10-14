# Project Board

## Overview

A GitHub Project is a board or table that pulls issues and pull requests from many repos into one view. The DBA Change Control board tracks every change request from intake to done.

| Status | Meaning |
| --- | --- |
| Intake | Not reviewed yet |
| Needs Evidence | Missing validation or rollback plan |
| Ready for Approval | Waiting on a DBA reviewer |
| Approved | Approved by a DBA |
| Scheduled | Booked into a deployment window |
| Done | Deployed and verified |

It also has Risk, Environment, and Rollback Ready fields.

## Value for DBAs

- One view of every change across every repo
- See high risk work and missing rollback plans at a glance
- Run the change meeting from one screen

## What it does and does not do

| Does | Does not |
| --- | --- |
| Shows issues and pull requests from many repos | Store the issues, which stay in their repos |
| Updates when an issue is closed or changed | Get copied when you create a repo from a template |
| Adds new issues automatically with Auto add | Enforce approvals, which happen in pull requests |
| Saves filtered views such as High Risk | Create views from the command line |

## How to create it

1. Click your profile picture, then Your projects, then New project.
2. Choose Board and name it `DBA Change Control`.
3. Rename the columns to the Status values above. Use the column menu to rename and the plus sign to add.
4. Open the three dots at the top right, then Settings, and add the Risk, Environment, and Rollback Ready fields as single select fields.
5. From the same menu open Workflows, turn on Auto add to project, and pick your repo.

## How to use it

1. Open the [DBA Change Control](https://github.com/users/amyabelsql/projects) board.
2. To get your own copy, click the three dots at the top right and choose Make a copy.
3. Move issues between columns as they progress, and set Risk and Rollback Ready on each one.
