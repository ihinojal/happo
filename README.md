# Happo

## What is appointment

Appoitment is a demo website where users can make online appointments
with a service like a doctor.

A **User** can:

- Register in the website and look for free appointments and choose one.
  He can also remove his account.

    GET /user/new     Form to create a new user
    DELETE /user      Remove account
    GET /session/new  Form to log in
    POST /session     Read log in data
    DELETE /session   Log out
    GET /profile/edit Form to update user data
    PUT /profile      Update the user data (first_name and last_name)
    GET /recover      Form to recover the password
    POST /recover     Process the password recovering

- Receives an email when he books an appointment.

    resources /appointments
      NOTE: index only shows its appointments

- Allow to send the satisfaction for that appointment

    POST /appointment/:id/satisfaction?token=H7q0t4N

A **Doctor** can:

- See all appointments in each day as a calendar.

    GET /appointments/?from_date=2017-10-11&to_date=2017-10-13&worker_id=1
    GET /appointments/:id

- Change the date of an appointment or any data of it (user is
  automatically notified)

    GET   /appointment/:id/edit
    PUT   /appointment/:id

- View all customers

    GET   /customers  Show customer profile and satisfaction

- Convert a user to a Doctor

    GET  /customer/:id/convert_to_doctor
    POST /customer/:id/convert_to_doctor

A **developer** can:

- Manage the API


DEVELOPMENT STEPS:

0. Install slim and sass
1. User login and registration email
2. Appointments
3. Convert user to doctor
4. Satisfaction
5. Deployment
6. Recover user password
7. Developer API (Optional)
