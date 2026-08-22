export interface GraveRecord {
  id?: number;
  roomId: string;
  rule: string;
  paranoia: number;
  timestamp: number;
}

export class GraveLogDb {
  private static db: IDBDatabase | null = null;

  static async init(): Promise<void> {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('TheLastMoveDB', 1);
      request.onupgradeneeded = (e) => {
        const db = (e.target as any).result as IDBDatabase;
        if (!db.objectStoreNames.contains('graves')) {
          db.createObjectStore('graves', { keyPath: 'id', autoIncrement: true });
        }
      };
      request.onsuccess = (e) => {
        this.db = (e.target as any).result;
        resolve();
      };
      request.onerror = (e) => reject((e.target as any).error);
    });
  }

  static async addGrave(grave: GraveRecord): Promise<void> {
    if (!this.db) return;
    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction('graves', 'readwrite');
      const store = tx.objectStore('graves');
      const req = store.add(grave);
      req.onsuccess = () => resolve();
      req.onerror = () => reject(req.error);
    });
  }

  static async getRecentGraves(limit = 5): Promise<GraveRecord[]> {
    if (!this.db) return [];
    return new Promise((resolve, reject) => {
      const tx = this.db!.transaction('graves', 'readonly');
      const store = tx.objectStore('graves');
      const req = store.openCursor(null, 'prev'); // descending
      const results: GraveRecord[] = [];
      
      req.onsuccess = (e) => {
        const cursor = (e.target as any).result as IDBCursorWithValue;
        if (cursor && results.length < limit) {
          results.push(cursor.value);
          cursor.continue();
        } else {
          resolve(results);
        }
      };
      req.onerror = () => reject(req.error);
    });
  }
}
