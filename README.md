# LMS API

This application provides a backend API to manage users, organizations, and authentication flows with roles such as **Global Admin**, **Organization Admin**, **Teacher**, and **Student**. It supports secure login with JWT and bcrypt, two-step verification for admins, organization-based access, and email notifications for new users with temporary passwords.

---

## Overview

The system supports two main user roles:

- **Global Admin:** Manages all organizations and organization admins.
- **Organization Admin:** Manages users within their organization.
- **Teachers and Students:** Belong to organizations and can log in to the system.


---

## Technologies Used

- Ruby on Rails (API mode), Ruby @3.2+
- PostgreSQL (with JSONB support)
- bcrypt (password hashing)
- JWT (JSON Web Tokens for auth)
- Sidekiq + Redis (background jobs for sending emails)
- ActiveModel Serializers (JSON serialization)
- Letter Opener (for email preview in development)

---

## Setup

First clone it to your local machine by running

```
https://github.com/magicmarie/MH-E-learning-Platform.git
cd MH-E-learning-Platform
```

Then install all the necessary dependencies and build the project

```
bundle install
```

## Setup database and seeds

At the terminal or console type:

```
rails reset_and_seed
```

## Starting/running the application

```
rails s
```
