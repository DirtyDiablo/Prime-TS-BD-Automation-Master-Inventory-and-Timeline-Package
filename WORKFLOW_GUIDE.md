# WORKFLOW_GUIDE.md

# 🚦 Prime TS BD Automation – AI Workflow Playbook

This guide explains **which AI model to use for each task** in the Master Inventory & Timeline Package project.  
Keep this file in the repo root so your **primary chat model** (GPT-5 Instant) can always remind you which tool to switch to.

---

## 🟢 GPT-5 Instant (Primary Orchestration)
**Use when:**  
- You need step-by-step instructions (“explain like I’m 5”)  
- High-level planning and roadmapping  
- Summarizing documents or meetings  
- Quick formatting of prompts, README outlines, or reports  

**Examples:**  
- *“Explain how to structure my repo like I’m new to GitHub.”*  
- *“Summarize the Final Project PDF into bullet points for my README.”*  

---

## 🔵 GPT-5 Pro with Deep Research
**Use when:**  
- Auditing **large sets of documents** (PDFs, JSONs, inventories, Drive listings)  
- Cross-checking **Master_Inventory.json** vs. Drive contents  
- Generating **reports of missing/misplaced artifacts**  
- Identifying **deltas between versions** (old vs. new artifacts, chat deltas, etc.)  

**Examples:**  
- *“Compare Step 1 – Decisions Made and Step 3 – Current State by Engine, list out all changes.”*  
- *“Audit Drive tree vs. Master Inventory JSON and give me a CSV of missing files.”*  

---

## 🔴 GPT-4o / Codex (Code + Repo Ops)
**Use when:**  
- Writing or editing **scripts** (PowerShell, Python, JSON schema, Markdown templates)  
- Maintaining files in your **GitHub repo**  
- Building or updating automation workflows (n8n, config JSONs, etc.)  
- Iteratively **fixing errors in scripts**  

**Examples:**  
- *“Generate a PowerShell script to move all artifacts into canonical folders.”*  
- *“Write a JSON schema for Master_Inventory.json and validate against my sample.”*  
- *“Update README.md to include usage instructions for fix-drive-structure.ps1.”*  

---

## ⚡ Workflow Template
1. **Plan** → Start in **GPT-5 Instant** to outline what you’re trying to do.  
2. **Audit** → Switch to **GPT-5 Pro + Deep Research** when you need a cross-document check or a gap analysis.  
3. **Build** → Move to **Codex (GPT-4o)** to generate scripts, configs, and repo commits.  
4. **Return** → Come back to **GPT-5 Instant** to summarize progress, plan next steps, or re-orchestrate.  

---

## 📂 Suggested Repo Placement
Save this file in your repo root as:  
