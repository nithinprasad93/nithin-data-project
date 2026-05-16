"""Send a styled HTML notification email via Resend. Called from GitHub Actions."""

import argparse
import os
from datetime import datetime

import resend

FROM_EMAIL = "me@nithin-prasad-portfolio.digital"

STATUS_CONFIG = {
    "failure": {
        "colour": "#dc2626",
        "bg":     "#fef2f2",
        "border": "#fca5a5",
        "icon":   "&#10060;",
        "label":  "FAILED",
    },
    "success": {
        "colour": "#16a34a",
        "bg":     "#f0fdf4",
        "border": "#86efac",
        "icon":   "&#9989;",
        "label":  "SUCCEEDED",
    },
}


def build_html(workflow: str, status: str, body: str, run_url: str, repo: str, run_id: str) -> str:
    cfg = STATUS_CONFIG.get(status, STATUS_CONFIG["failure"])
    timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")

    rows = [
        ("Workflow",   workflow),
        ("Repository", repo),
        ("Run ID",     run_id),
        ("Time",       timestamp),
        ("Status",     f"<strong style='color:{cfg['colour']}'>{cfg['icon']} {cfg['label']}</strong>"),
    ]
    table_rows = "".join(
        f"""
        <tr>
          <td style="padding:8px 12px;color:#6b7280;font-size:13px;white-space:nowrap">{k}</td>
          <td style="padding:8px 12px;font-size:13px">{v}</td>
        </tr>"""
        for k, v in rows
    )

    return f"""
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f3f4f6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif">
  <table width="100%" cellpadding="0" cellspacing="0" style="padding:32px 0">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1)">

        <!-- Header -->
        <tr>
          <td style="background:{cfg['colour']};padding:24px 32px">
            <p style="margin:0;color:#ffffff;font-size:12px;text-transform:uppercase;letter-spacing:1px">Horizon Allied Health</p>
            <h1 style="margin:4px 0 0;color:#ffffff;font-size:22px;font-weight:600">
              Pipeline {cfg['label']} {cfg['icon']}
            </h1>
          </td>
        </tr>

        <!-- Status banner -->
        <tr>
          <td style="background:{cfg['bg']};border-bottom:1px solid {cfg['border']};padding:12px 32px">
            <p style="margin:0;font-size:13px;color:{cfg['colour']}">{body}</p>
          </td>
        </tr>

        <!-- Details table -->
        <tr>
          <td style="padding:24px 32px 8px">
            <p style="margin:0 0 12px;font-size:12px;text-transform:uppercase;letter-spacing:1px;color:#9ca3af">Run Details</p>
            <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e5e7eb;border-radius:6px;overflow:hidden">
              {table_rows}
            </table>
          </td>
        </tr>

        <!-- CTA button -->
        <tr>
          <td style="padding:16px 32px 32px">
            <a href="{run_url}"
               style="display:inline-block;background:{cfg['colour']};color:#ffffff;text-decoration:none;padding:10px 20px;border-radius:6px;font-size:13px;font-weight:600">
              View Run in GitHub Actions &rarr;
            </a>
          </td>
        </tr>

        <!-- Footer -->
        <tr>
          <td style="background:#f9fafb;border-top:1px solid #e5e7eb;padding:16px 32px">
            <p style="margin:0;font-size:11px;color:#9ca3af">
              This is an automated alert from the Horizon Allied Health data platform.
              Sent by Firehawk Analytics.
            </p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>
"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--subject",  required=True)
    parser.add_argument("--body",     required=True)
    parser.add_argument("--status",   default="failure", choices=["failure", "success"])
    parser.add_argument("--workflow", default="Pipeline")
    parser.add_argument("--run-url",  default="")
    parser.add_argument("--repo",     default="")
    parser.add_argument("--run-id",   default="")
    args = parser.parse_args()

    resend.api_key = os.environ["RESEND_API_KEY"]
    to_email = os.environ["NOTIFY_EMAIL"]

    html = build_html(
        workflow=args.workflow,
        status=args.status,
        body=args.body,
        run_url=args.run_url,
        repo=args.repo,
        run_id=args.run_id,
    )

    resend.Emails.send({
        "from":    FROM_EMAIL,
        "to":      to_email,
        "subject": args.subject,
        "html":    html,
        "text":    args.body,  # plain-text fallback
    })

    print(f"Email sent to {to_email}: {args.subject}")


if __name__ == "__main__":
    main()
