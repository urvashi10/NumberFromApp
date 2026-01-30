#!/usr/bin/env python3
"""
MCP Filesystem Server
Provides file system operations for the Robot Framework project
"""

import asyncio
import os
from pathlib import Path
from mcp.server import Server
from mcp.types import Tool, TextContent
import mcp.server.stdio

# Get the directory where this script is located
BASE_DIR = Path(__file__).parent.absolute()

app = Server("project_fs")

@app.list_tools()
async def list_tools() -> list[Tool]:
    """List available filesystem tools"""
    return [
        Tool(
            name="read_file",
            description="Read the contents of a file",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Relative path to the file from project root"
                    }
                },
                "required": ["path"]
            }
        ),
        Tool(
            name="write_file",
            description="Write content to a file (creates if doesn't exist)",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Relative path to the file from project root"
                    },
                    "content": {
                        "type": "string",
                        "description": "Content to write to the file"
                    }
                },
                "required": ["path", "content"]
            }
        ),
        Tool(
            name="list_directory",
            description="List files and directories in a given path",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Relative path to the directory from project root (use '.' for root)",
                        "default": "."
                    }
                }
            }
        ),
        Tool(
            name="create_directory",
            description="Create a new directory",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Relative path to the directory to create"
                    }
                },
                "required": ["path"]
            }
        ),
        Tool(
            name="delete_file",
            description="Delete a file",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": "Relative path to the file to delete"
                    }
                },
                "required": ["path"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Handle tool calls"""
    
    try:
        if name == "read_file":
            file_path = BASE_DIR / arguments["path"]
            if not file_path.exists():
                return [TextContent(
                    type="text",
                    text=f"Error: File not found: {arguments['path']}"
                )]
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            return [TextContent(
                type="text",
                text=f"Content of {arguments['path']}:\n\n{content}"
            )]
        
        elif name == "write_file":
            file_path = BASE_DIR / arguments["path"]
            file_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(arguments["content"])
            
            return [TextContent(
                type="text",
                text=f"Successfully wrote to {arguments['path']}"
            )]
        
        elif name == "list_directory":
            dir_path = BASE_DIR / arguments.get("path", ".")
            
            if not dir_path.exists():
                return [TextContent(
                    type="text",
                    text=f"Error: Directory not found: {arguments.get('path', '.')}"
                )]
            
            items = []
            for item in sorted(dir_path.iterdir()):
                item_type = "DIR" if item.is_dir() else "FILE"
                rel_path = item.relative_to(BASE_DIR)
                items.append(f"{item_type}: {rel_path}")
            
            return [TextContent(
                type="text",
                text=f"Contents of {arguments.get('path', '.')}:\n\n" + "\n".join(items)
            )]
        
        elif name == "create_directory":
            dir_path = BASE_DIR / arguments["path"]
            dir_path.mkdir(parents=True, exist_ok=True)
            
            return [TextContent(
                type="text",
                text=f"Successfully created directory: {arguments['path']}"
            )]
        
        elif name == "delete_file":
            file_path = BASE_DIR / arguments["path"]
            
            if not file_path.exists():
                return [TextContent(
                    type="text",
                    text=f"Error: File not found: {arguments['path']}"
                )]
            
            file_path.unlink()
            
            return [TextContent(
                type="text",
                text=f"Successfully deleted: {arguments['path']}"
            )]
        
        else:
            return [TextContent(
                type="text",
                text=f"Error: Unknown tool: {name}"
            )]
    
    except Exception as e:
        return [TextContent(
            type="text",
            text=f"Error executing {name}: {str(e)}"
        )]

async def main():
    """Run the MCP server"""
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
