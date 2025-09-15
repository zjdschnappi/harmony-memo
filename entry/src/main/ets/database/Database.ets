
import { BusinessError } from '@ohos.base';

import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';

const DB_NAME = 'memo_db.db';
const DB_VERSION = 1;

// 数据库表结构
const TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS memos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    memo_id TEXT UNIQUE NOT NULL,
    title TEXT,
    content TEXT,             -- JSON序列化内容
    content_version INTEGER DEFAULT 1,
    is_pinned BOOLEAN DEFAULT 0,
    is_archived BOOLEAN DEFAULT 0,
    created_time INTEGER NOT NULL,
    modified_time INTEGER NOT NULL
  )
`;
// 数据库表结构
const TODO_SQL = `
  CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    todo_id TEXT UNIQUE NOT NULL,
    title TEXT,
    priority INTEGER DEFAULT 3,
    is_completed BOOLEAN DEFAULT 0,
    created_time INTEGER NOT NULL,
    modified_time INTEGER NOT NULL,
    due_time INTEGER,
    location_name TEXT,
    latitude INTEGER,
    longitude INTEGER,
    radius INTEGER,
    memo TEXT
  )
`;

// 创建索引
const INDEX_SQL = `
  CREATE INDEX IF NOT EXISTS idx_memos_pinned ON memos(is_pinned);
  CREATE INDEX IF NOT EXISTS idx_memos_created ON memos(created_time);
`;

class Database {
  private static instance: relationalStore.RdbStore;

  // 初始化数据库
  static async init(context?:common.UIAbilityContext): Promise<void> {

      return new Promise((resolve,reject)=>{
        const config: relationalStore.StoreConfig = {
          name: DB_NAME,
          securityLevel: relationalStore.SecurityLevel.S1,
          encrypt: true
        };

        relationalStore.getRdbStore(context, config,(err,rdb)=>{
          if(!err){
            Database.instance = rdb
            Database.instance.executeSql(TABLE_SQL);
            Database.instance.executeSql(INDEX_SQL);
            Database.instance.executeSql(TODO_SQL);
            resolve()
          }else {
            reject()
          }
        });

        console.log('Database initialized successfully');
      })


  }

  static async getRdbStore(): Promise<relationalStore.RdbStore> {
    if (!Database.instance) {
      await Database.init();
    }
    return Database.instance;
  }
}

export default Database;