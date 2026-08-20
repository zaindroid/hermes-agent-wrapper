"use strict";

// Shared nav rail rendered into #shell-nav on every page. Each page calls
// renderShell("<page-id>") once on load.

const NAV_GROUPS = [
  {
    label: "Agent",
    items: [
      { id: "chat", label: "Chat (classic)", href: "/", icon: "chat" },
      { id: "bots", label: "Bots", href: "/bots/", icon: "bots" },
      { id: "sessions", label: "Sessions", href: "/bots/sessions.html", icon: "sessions" },
      { id: "cron", label: "Routines", href: "/bots/cron.html", icon: "cron" },
      { id: "skills", label: "Skills", href: "/bots/skills.html", icon: "skills" },
    ],
  },
  {
    label: "Configuration",
    items: [
      { id: "models", label: "Models", href: "/bots/models.html", icon: "models" },
      { id: "mcp", label: "MCP Servers", href: "/bots/mcp.html", icon: "mcp" },
      { id: "config", label: "Config", href: "/bots/config.html", icon: "config" },
      { id: "env", label: "Environment", href: "/bots/env.html", icon: "env" },
    ],
  },
  {
    label: "Platform",
    items: [
      { id: "plugins", label: "Plugins", href: "/bots/plugins.html", icon: "plugins" },
      { id: "webhooks", label: "Webhooks", href: "/bots/webhooks.html", icon: "webhooks" },
      { id: "files", label: "Files", href: "/bots/files.html", icon: "files" },
      { id: "logs", label: "Logs", href: "/bots/logs.html", icon: "logs" },
      { id: "system", label: "System", href: "/bots/system.html", icon: "system" },
    ],
  },
];

function renderShell(activeId) {
  const nav = document.getElementById("shell-nav");
  if (!nav) return;

  const brand = document.createElement("div");
  brand.id = "shell-nav-brand";
  brand.innerHTML = `${icon("system", 20)}<span>Hermes</span>`;
  nav.appendChild(brand);

  NAV_GROUPS.forEach((group) => {
    const label = document.createElement("div");
    label.className = "shell-nav-group-label";
    label.textContent = group.label;
    nav.appendChild(label);

    group.items.forEach((item) => {
      const a = document.createElement("a");
      a.className = "shell-nav-link" + (item.id === activeId ? " active" : "");
      a.href = item.href;
      a.innerHTML = `${icon(item.icon, 17)}<span>${item.label}</span>`;
      nav.appendChild(a);
    });
  });
}
