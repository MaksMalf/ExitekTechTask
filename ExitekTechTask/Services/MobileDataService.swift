import Foundation
import CoreData

protocol MobileStorage {
    func getAll() -> Set<Mobile>
    func findByImei(_ imei: String) -> Mobile?
    func save(_ mobile: Mobile) throws -> Mobile
    func delete(_ product: Mobile) throws
    func exists(_ product: Mobile) -> Bool
}

class MobileDataService: MobileStorage {

    // MARK: - Propertries
    static let sharedManager = MobileDataService()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExitekTechTask")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var context = persistentContainer.viewContext

    // MARK: - Functions

    func save(_ mobile: Mobile) throws -> Mobile {
        let newMobileEntity = MobileEntity(context: context)
        newMobileEntity.imei = mobile.imei
        newMobileEntity.model = mobile.model
        do {
            try context.save()
            return mobile
        } catch {
            throw error
        }
    }
//
    func getAll() -> Set<Mobile> {
        do {
            var mobiles: [Mobile] = []
            let request = MobileEntity.fetchRequest() as NSFetchRequest<MobileEntity>
            let mobilesEntity = try context.fetch(request)
            mobilesEntity.forEach { mobileEntity in
                let mob = Mobile(imei: mobileEntity.imei ?? "", model: mobileEntity.model ?? "")
                mobiles.append(mob)
            }
            return Set(mobiles)
        } catch {
            return Set<Mobile>()
        }
    }
//
    func delete(_ product: Mobile) throws {
        let request = MobileEntity.fetchRequest() as NSFetchRequest<MobileEntity>
        let mobilesEntity = try context.fetch(request)
        mobilesEntity.forEach { entity in
            if entity.imei == product.imei {
                context.delete(entity)
            }
        }
        do {
            try context.save()
        } catch {
            throw error
        }
    }

    func findByImei(_ imei: String) -> Mobile? {
        let mobiles = getAll()
        var searchResult: Mobile?
        mobiles.forEach { mobile in
            if mobile.imei == imei {
                searchResult = mobile
            }
        }
        
        return searchResult
    }

    func exists(_ product: Mobile) -> Bool {
        let mobiles = getAll()
        return mobiles.contains(product)
    }


}

// MARK: - Core Data Saving support

extension MobileDataService {
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
