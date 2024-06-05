import sys
import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from email_validator import validate_email, EmailNotValidError


def send_email(file_path, recipient_email):
    # Thông tin về email và mật khẩu của bạn
    sender_email = ""
    sender_password = "" #app password

    # Tạo nội dung email
    subject = "Here is your file"
    body = "Please find the attached file."

    # Tạo đối tượng MIMEMultipart
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = subject

    # Thêm phần thân email vào msg
    msg.attach(MIMEText(body, 'plain'))

    # Xử lý file đính kèm
    if os.path.isfile(file_path):
        attachment = open(file_path, "rb")

        part = MIMEBase('application', 'octet-stream')
        part.set_payload((attachment).read())
        encoders.encode_base64(part)
        part.add_header('Content-Disposition', f"attachment; filename= {os.path.basename(file_path)}")

        msg.attach(part)
    else:
        print(f"File {file_path} does not exist")
        sys.exit(1)

    # Kết nối tới server và gửi email
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, sender_password)
        text = msg.as_string()
        server.sendmail(sender_email, recipient_email, text)
        server.quit()
        print(f"Email sent to {recipient_email}")
    except Exception as e:
        print(f"Failed to send email: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    # Kiểm tra số lượng tham số
    if len(sys.argv) != 3:
        print("Usage: send.py [file_path] [to@gmail.com]")
        sys.exit(1)

    file_path = sys.argv[1]
    recipient_email = sys.argv[2]

    # Kiểm tra tính hợp lệ của địa chỉ email
    try:
        v = validate_email(recipient_email)
        recipient_email = v["email"]
    except EmailNotValidError as e:
        print(str(e))
        sys.exit(1)

    send_email(file_path, recipient_email)
