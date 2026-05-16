"""Send a styled HTML notification email via Resend. Called from GitHub Actions."""

import argparse
import os
from datetime import datetime

import resend

FROM_EMAIL = "me@nithin-prasad-portfolio.digital"

STATUS_CONFIG = {
    "failure": {
        "colour":      "#dc2626",
        "bg":          "#fef2f2",
        "border":      "#fca5a5",
        "header_bg":   "#dc2626",
        "icon":        "&#10060;",
        "label":       "FAILED",
        "badge_bg":    "#fee2e2",
        "badge_color": "#991b1b",
    },
    "success": {
        "colour":      "#16a34a",
        "bg":          "#f0fdf4",
        "border":      "#86efac",
        "header_bg":   "#16a34a",
        "icon":        "&#9989;",
        "label":       "SUCCEEDED",
        "badge_bg":    "#dcfce7",
        "badge_color": "#166534",
    },
}

WORKFLOW_META = {
    "Daily Data Seed": {
        "description": "Generates daily NDIS operational data (appointments, invoices, timesheets) and loads it into Snowflake RAW layer.",
        "icon": "&#128190;",
        "target": "Snowflake RAW",
        "role": "SVC_LOADER / NDIS_LOADER",
    },
    "dbt Transform": {
        "description": "Runs dbt source freshness checks, transforms RAW → STAGING → MARTS, and executes all data quality tests.",
        "icon": "&#9881;&#65039;",
        "target": "Snowflake STAGING + MARTS",
        "role": "SVC_TRANSFORMER / NDIS_TRANSFORMER",
    },
    "Deploy Evidence.dev": {
        "description": "Triggers a Vercel rebuild of the Evidence.dev dashboard, pulling fresh data from Snowflake MARTS.",
        "icon": "&#128202;",
        "target": "Vercel (Evidence.dev)",
        "role": "SVC_REPORTER / NDIS_REPORTER",
    },
}


def detail_row(label: str, value: str) -> str:
    return f"""
      <tr>
        <td style="padding:10px 16px;font-size:13px;color:#6b7280;white-space:nowrap;border-bottom:1px solid #f3f4f6;width:160px">{label}</td>
        <td style="padding:10px 16px;font-size:13px;color:#111827;border-bottom:1px solid #f3f4f6">{value}</td>
      </tr>"""


def build_html(
    workflow: str,
    status: str,
    body: str,
    run_url: str,
    repo: str,
    run_id: str,
    branch: str,
    actor: str,
    trigger: str,
    duration: str,
    extra_rows: list[tuple[str, str]],
) -> str:
    cfg = STATUS_CONFIG.get(status, STATUS_CONFIG["failure"])
    meta = WORKFLOW_META.get(workflow, {})
    timestamp = datetime.utcnow().strftime("%A, %d %B %Y at %H:%M UTC")
    repo_url = f"https://github.com/{repo}"

    badge = (
        f"<span style='display:inline-block;padding:2px 10px;border-radius:12px;"
        f"background:{cfg['badge_bg']};color:{cfg['badge_color']};"
        f"font-size:12px;font-weight:700'>{cfg['icon']} {cfg['label']}</span>"
    )

    standard_rows = [
        ("Status",      badge),
        ("Workflow",    workflow),
        ("Repository",  f"<a href='{repo_url}' style='color:#2563eb'>{repo}</a>"),
        ("Branch",      branch or "main"),
        ("Triggered by", trigger or "schedule"),
        ("Actor",       actor or "github-actions"),
        ("Run ID",      f"<a href='{run_url}' style='color:#2563eb'>#{run_id}</a>"),
        ("Timestamp",   timestamp),
        ("Duration",    duration or "—"),
    ] + extra_rows

    all_rows = "".join(detail_row(k, v) for k, v in standard_rows)

    workflow_desc = meta.get("description", "")
    workflow_icon = meta.get("icon", "&#9654;")
    target = meta.get("target", "—")
    role = meta.get("role", "—")

    infra_rows = "".join([
        detail_row("Target system", target),
        detail_row("Snowflake role", role),
        detail_row("Environment", "Production"),
    ])

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>{workflow} — {cfg['label']}</title>
</head>
<body style="margin:0;padding:0;background:#f3f4f6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif">
<table width="100%" cellpadding="0" cellspacing="0" style="padding:32px 16px">
<tr><td align="center">
<table width="620" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:10px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08)">

  <!-- ── Header ── -->
  <tr>
    <td style="background:{cfg['header_bg']};padding:28px 32px">
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr>
          <td>
            <p style="margin:0 0 4px;color:rgba(255,255,255,0.8);font-size:11px;text-transform:uppercase;letter-spacing:1.5px">Horizon Allied Health · Data Platform</p>
            <h1 style="margin:0;color:#ffffff;font-size:24px;font-weight:700;line-height:1.2">
              {workflow_icon} {workflow}
            </h1>
            <p style="margin:6px 0 0;color:rgba(255,255,255,0.9);font-size:14px">{cfg['icon']} Pipeline {cfg['label']}</p>
          </td>
        </tr>
      </table>
    </td>
  </tr>

  <!-- ── Summary banner ── -->
  <tr>
    <td style="background:{cfg['bg']};border-left:4px solid {cfg['colour']};padding:14px 32px">
      <p style="margin:0;font-size:14px;color:{cfg['colour']};font-weight:500">{body}</p>
    </td>
  </tr>

  <!-- ── Workflow description ── -->
  <tr>
    <td style="padding:20px 32px 0">
      <p style="margin:0;font-size:13px;color:#6b7280;line-height:1.6">{workflow_desc}</p>
    </td>
  </tr>

  <!-- ── Run details ── -->
  <tr>
    <td style="padding:20px 32px 0">
      <p style="margin:0 0 8px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:#9ca3af">Run Details</p>
      <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e5e7eb;border-radius:8px;overflow:hidden">
        {all_rows}
      </table>
    </td>
  </tr>

  <!-- ── Infrastructure ── -->
  <tr>
    <td style="padding:20px 32px 0">
      <p style="margin:0 0 8px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:1px;color:#9ca3af">Infrastructure</p>
      <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #e5e7eb;border-radius:8px;overflow:hidden">
        {infra_rows}
      </table>
    </td>
  </tr>

  <!-- ── CTA ── -->
  <tr>
    <td style="padding:24px 32px">
      <a href="{run_url}"
         style="display:inline-block;background:{cfg['colour']};color:#ffffff;text-decoration:none;padding:11px 22px;border-radius:7px;font-size:13px;font-weight:600;letter-spacing:0.3px">
        View Run in GitHub Actions &rarr;
      </a>
      &nbsp;
      <a href="{repo_url}/actions"
         style="display:inline-block;background:#f9fafb;border:1px solid #e5e7eb;color:#374151;text-decoration:none;padding:11px 22px;border-radius:7px;font-size:13px;font-weight:500">
        All Workflows
      </a>
    </td>
  </tr>

  <!-- ── Footer ── -->
  <tr>
    <td style="background:#f9fafb;border-top:1px solid #e5e7eb;padding:16px 32px">
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr>
          <td>
            <p style="margin:0;font-size:11px;color:#9ca3af">
              Automated alert · Horizon Allied Health Data Platform · Powered by Firehawk Analytics
            </p>
          </td>
          <td align="right">
            <p style="margin:0;font-size:11px;color:#9ca3af">{timestamp}</p>
          </td>
        </tr>
      </table>
    </td>
  </tr>

</table>
</td></tr>
</table>
</body>
</html>"""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--subject",   required=True)
    parser.add_argument("--body",      required=True)
    parser.add_argument("--status",    default="failure", choices=["failure", "success"])
    parser.add_argument("--workflow",  default="Pipeline")
    parser.add_argument("--run-url",   default="")
    parser.add_argument("--repo",      default="")
    parser.add_argument("--run-id",    default="")
    parser.add_argument("--branch",    default="")
    parser.add_argument("--actor",     default="")
    parser.add_argument("--trigger",   default="")
    parser.add_argument("--duration",  default="")
    # Extra key=value pairs, e.g. --extra "Seed date=2026-05-17" "Models run=21"
    parser.add_argument("--extra",     nargs="*", default=[])
    args = parser.parse_args()

    extra_rows = []
    for item in args.extra or []:
        if "=" in item:
            k, v = item.split("=", 1)
            extra_rows.append((k.strip(), v.strip()))

    resend.api_key = os.environ["RESEND_API_KEY"]
    to_email = os.environ["NOTIFY_EMAIL"]

    html = build_html(
        workflow=args.workflow,
        status=args.status,
        body=args.body,
        run_url=args.run_url,
        repo=args.repo,
        run_id=args.run_id,
        branch=args.branch,
        actor=args.actor,
        trigger=args.trigger,
        duration=args.duration,
        extra_rows=extra_rows,
    )

    resend.Emails.send({
        "from":    FROM_EMAIL,
        "to":      to_email,
        "subject": args.subject,
        "html":    html,
        "text":    args.body,
    })

    print(f"Email sent to {to_email}: {args.subject}")


if __name__ == "__main__":
    main()
