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
        let request = MobileEntity.fetchRequest() as NSFetchRequest<MobileEntity>
        request.predicate = NSPredicate(format: "imei == %@", mobile.imei)

        do {
            let mobilesEntity = try context.fetch(request)
            print(mobilesEntity.count)
            if mobilesEntity.count > 0 {
                throw SavingErrors.duplicate
            }
        } catch {
            throw error
        }

        if mobile.imei.count != 15 {
            throw SavingErrors.nonCorrectData
        }

        let newMobileEntity = MobileEntity(context: context)
        newMobileEntity.imei = mobile.imei
        newMobileEntity.model = mobile.model

        do {
            try context.save()
            return mobile
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

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
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")        }
    }

    func delete(_ product: Mobile) throws {
        let request = MobileEntity.fetchRequest() as NSFetchRequest<MobileEntity>
        let mobilesEntity = try context.fetch(request)
        if mobilesEntity.count == 0 {
            throw DeletionErrors.dataBaseIsEmpty
        }
        var deleteEntity: MobileEntity?
        mobilesEntity.forEach { entity in
            if entity.imei == product.imei {
                deleteEntity = entity
            }
        }

        if let deleteEntity = deleteEntity {
            context.delete(deleteEntity)
        } else {
            throw DeletionErrors.mobileNotFound
        }

        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")

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

// MARK: - Possible errors

enum SavingErrors: Error {
    case duplicate
    case nonCorrectData
}

enum DeletionErrors: Error {
    case mobileNotFound
    case dataBaseIsEmpty
}

extension SavingErrors: CustomStringConvertible {
    var description: String {
        switch self {
        case .duplicate: return "Such a mobile is already in the database"
        case .nonCorrectData: return "Incorrect data has been entered"
        }
    }
}

extension DeletionErrors: CustomStringConvertible {
    var description: String {
        switch self {
        case .mobileNotFound: return "There is no mobile with such an IMEI in the database"
        case .dataBaseIsEmpty: return "The database is empty"
        }
    }
}
