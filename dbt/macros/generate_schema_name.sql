-- Override dbt's default schema naming so models land in the correct
-- Snowflake schema regardless of the profile's default_schema setting.
-- Without this, dbt prefixes schema names with the target schema (e.g. STAGING_MARTS).

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | upper | trim }}
    {%- endif -%}
{%- endmacro %}
