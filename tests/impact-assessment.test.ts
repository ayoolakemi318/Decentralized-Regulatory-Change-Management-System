import { describe, it, expect, beforeEach } from "vitest"

describe("Impact Assessment Contract", () => {
  let mockContract
  let mockAdmin
  let mockUser
  
  beforeEach(() => {
    mockAdmin = { address: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM" }
    mockUser = { address: "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG" }
    
    // Mock contract state
    mockContract = {
      admin: mockAdmin.address,
      impactAssessments: {},
      
      addImpactAssessment(caller, assessmentId, requirementId, impactLevel, affectedAreas, notes) {
        if (caller.address !== this.admin) {
          return { type: "err", value: 1 }
        }
        
        if (this.impactAssessments[assessmentId]) {
          return { type: "err", value: 2 }
        }
        
        this.impactAssessments[assessmentId] = {
          requirementId,
          impactLevel,
          affectedAreas,
          assessmentDate: 123, // Mock block height
          assessor: caller.address,
          notes,
        }
        
        return { type: "ok", value: true }
      },
      
      getImpactAssessment(assessmentId) {
        return this.impactAssessments[assessmentId] || null
      },
      
      setAdmin(caller, newAdmin) {
        if (caller.address !== this.admin) {
          return { type: "err", value: 1 }
        }
        
        this.admin = newAdmin
        return { type: "ok", value: true }
      },
    }
  })
  
  it("should allow admin to add an impact assessment", () => {
    const result = mockContract.addImpactAssessment(
        mockAdmin,
        "impact-001",
        "req-001",
        "HIGH",
        "IT Systems, Customer Data",
        "Significant changes required to IT infrastructure",
    )
    
    expect(result.type).toBe("ok")
    expect(mockContract.impactAssessments["impact-001"]).toBeDefined()
    expect(mockContract.impactAssessments["impact-001"].impactLevel).toBe("HIGH")
  })
  
  it("should not allow non-admin to add an impact assessment", () => {
    const result = mockContract.addImpactAssessment(
        mockUser,
        "impact-002",
        "req-001",
        "MEDIUM",
        "Financial Reporting",
        "Updates to reporting procedures required",
    )
    
    expect(result.type).toBe("err")
    expect(result.value).toBe(1)
    expect(mockContract.impactAssessments["impact-002"]).toBeUndefined()
  })
  
  it("should retrieve impact assessment details", () => {
    mockContract.addImpactAssessment(
        mockAdmin,
        "impact-003",
        "req-001",
        "LOW",
        "Documentation",
        "Minor updates to documentation required",
    )
    
    const assessment = mockContract.getImpactAssessment("impact-003")
    expect(assessment).toBeDefined()
    expect(assessment.impactLevel).toBe("LOW")
    
    const nonExistentAssessment = mockContract.getImpactAssessment("non-existent")
    expect(nonExistentAssessment).toBeNull()
  })
})
