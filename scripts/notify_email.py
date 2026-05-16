"""Send a notification email via Resend. Called from GitHub Actions on pipeline failure."""

import argparse
import os
import resend


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--subject", required=True)
    parser.add_argument("--body", required=True)
    args = parser.parse_args()

    resend.api_key = os.environ["RESEND_API_KEY"]
    to_email = os.environ["NOTIFY_EMAIL"]

    resend.Emails.send({
        "from": "onboarding@resend.dev",
        "to": to_email,
        "subject": args.subject,
        "text": args.body,
    })

    print(f"Email sent to {to_email}: {args.subject}")


if __name__ == "__main__":
    main()
